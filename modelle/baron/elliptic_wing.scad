// elliptic_wing.scad – Elliptischer Halbflügel (Per-Slice Architektur)
// Jede Scheibe wird komplett in 2D berechnet, dann extrudiert.
// Keine verschachtelten 3D-Booleans mehr.

use <../../lib/airfoil.scad>
use <../../lib/grooves.scad>

// === Parameter ===
// Diese Datei ist ein Geometrie-Kern.
// Die Parameter werden von aufrufenden Dateien gesetzt (z.B. `wing.scad`, `tailplane.scad`).

function seg_boundary(i) = segment_bounds[i];

// === Funktionen ===

// Elliptische Profiltiefe
function elliptic_chord(y) =
    max(tip_min, chord_root * sqrt(1 - pow(min(y, half_span) / half_span, 2)));

// Leading-Edge Versatz: 30%-Linie bleibt gerade
function le_offset(y) = sweep_ref * (chord_root - elliptic_chord(y));

// V-Form Versatz
function v_offset(y) = tan(v_angle) * y;

// Schränkung (Washout): linear ab washout_start
function twist(y) =
    y <= washout_start ? 0 :
    washout * (y - washout_start) / (half_span - washout_start);

// Scharnier-X (absolute Koordinate) als lineare Funktion der Spannweite
// Definiert über inneren Referenzpunkt (aileron_y1 + aileron_hinge_pct)
// und Sweep-Winkel der Scharnierachse.
function hinge_x(y) =
    let(
        hx_root = le_offset(aileron_y1) + aileron_hinge_pct * elliptic_chord(aileron_y1)
    )
    hx_root + tan(aileron_hinge_sweep) * (y - aileron_y1);

// Scharnier-X in lokalen Profilkoordinaten (relativ zur Vorderkante)
// Nutzt die gerade absolute Linie hinge_x(), umgerechnet in lokale Coords
function hinge_x_local(y) = hinge_x(y) - le_offset(y);

// Aileron-Zonen: Wo liegt y relativ zum Querruder?
//   "none"    – kein Querruder
//   "closure" – Abschlusswand (massiv hinter Scharnier)
//   "gap"     – Spalt (kein Material hinter/vor Scharnier)
//   "aileron" – Querruder-Bereich (Schnitt an Scharnierlinie)
function aileron_zone(y) =
    // Vordere Abschlusswand Flügel
    (y >= aileron_y1 - aileron_gap && y < aileron_y1 - aileron_gap/2) ? "closure_wing" :
    // Vorderer Spalt
    (y >= aileron_y1 - aileron_gap/2 && y < aileron_y1 + aileron_gap/2) ? "gap" :
    // Vordere Abschlusswand Ruder
    (y >= aileron_y1 + aileron_gap/2 && y < aileron_y1 + aileron_gap) ? "closure_aileron" :
    // Querruder-Bereich (Flügel + Ruder getrennt)
    (y >= aileron_y1 + aileron_gap && y < aileron_y2 - aileron_gap) ? "aileron" :
    // Hintere Abschlusswand Ruder
    (y >= aileron_y2 - aileron_gap && y < aileron_y2 - aileron_gap/2) ? "closure_aileron" :
    // Hinterer Spalt
    (y >= aileron_y2 - aileron_gap/2 && y < aileron_y2 + aileron_gap/2) ? "gap" :
    // Hintere Abschlusswand Flügel
    (y >= aileron_y2 + aileron_gap/2 && y < aileron_y2 + aileron_gap) ? "closure_wing" :
    "none";

// Drehpunkt für Keil-Schnitt: Profiloberseite am Scharnierort
// Gibt [x, y] in lokalen Profilkoordinaten zurück
// Nutzt hinge_x_local() für gerade Scharnierlinie
function _hinge_pivot(y) =
    let(
        c = elliptic_chord(y),
        x_norm = hinge_x_local(y) / c,
        m = wing_naca[0], p = wing_naca[1], tt = wing_naca[2],
        yc = naca_camber(m, p, x_norm),
        yt = naca_half_thickness(tt, x_norm),
        th = atan2(naca_camber_gradient(m, p, x_norm), 1)
    )
    [c * (x_norm - yt * sin(th)),
     c * (yc + yt * cos(th))];

// Rückwand: dünne vertikale Wand an der Scharnierlinie
// Verschließt den hohlen Flügel-Innenraum nach hinten.
// offset: Wand endet bei hinge_x - offset (für Spalt-Berücksichtigung)
module _hinge_wall_2d(y, offset = 0) {
    hx = hinge_x_local(y);
    intersection() {
        slice_profile_2d(y);
        translate([hx - offset - wall, -50])
            square([wall, 100]);
    }
}

// Vorderwand Querruder: dünne vertikale Wand hinter der Scharnierlinie
// Verschließt den hohlen Querruder-Innenraum nach vorne.
module _hinge_wall_rear_2d(y, offset = 0) {
    hx = hinge_x_local(y);
    intersection() {
        slice_profile_2d(y);
        translate([hx + offset, -50])
            square([wall, 100]);
    }
}

// 2D-Schnittmaske: alles VOR der Scharnierlinie (senkrecht)
module _clip_front_2d(y, clearance = 0) {
    hx = hinge_x_local(y);
    intersection() {
        children();
        translate([-10, -50])
            square([hx + 10 - clearance, 100]);
    }
}

// 2D-Schnittmaske: alles HINTER der Scharnierlinie (senkrecht)
module _clip_rear_vertical_2d(y, clearance = 0) {
    c = elliptic_chord(y);
    hx = hinge_x_local(y);
    intersection() {
        children();
        translate([hx + clearance, -50])
            square([c - hx + 10, 100]);
    }
}

// 2D-Schnittmaske: alles HINTER der Keil-Linie (schräg, nur für Ruder)
module _clip_rear_bevel_2d(y, clearance = 0) {
    pv = _hinge_pivot(y);
    big = chord_root * 2;
    intersection() {
        children();
        translate(pv)
            rotate([0, 0, aileron_bevel])
                translate([clearance, -big])
                    square([big, 2 * big]);
    }
}

// Schräge Vorderwand Querruder: wall-breiter Streifen entlang der Bevel-Linie
// Verschließt den hohlen Querruder-Innenraum an der Schräge.
module _bevel_wall_2d(y, offset = 0) {
    pv = _hinge_pivot(y);
    big = chord_root * 2;
    intersection() {
        slice_profile_2d(y);
        translate(pv)
            rotate([0, 0, aileron_bevel])
                translate([offset, -big])
                    square([wall, 2 * big]);
    }
}

// === Kreuzrippen: X-Positionen bei Spannweite y ===
// Gibt eine Liste von X-Mittelpunkten zurück, an denen Rippenstreifen
// den Schnitt bei Spannweite y kreuzen. Beide Richtungen (+angle, -angle).
// Rippen verlaufen von z=0 schräg nach außen, Abstand rib_spacing entlang Z.

// Scheinbare Streifenbreite im Schnitt (Rippe steht schräg zur Scheibe)
// rib_wall ist die gewünschte Breite im Slice (= was der Slicer sieht)
rib_apparent_w = rib_wall;

function _rib_x_positions(y, angle, offset = 0) =
    let(
        dx_per_z = tan(angle),
        pitch = rib_spacing,
        x_base = dx_per_z * y + offset,
        n_min = floor((0 - x_base) / pitch) - 1,
        n_max = ceil((chord_root - x_base) / pitch) + 1
    )
    [for (n = [n_min : n_max])
        let(x = x_base + n * pitch)
        if (x > -chord_root && x < 2 * chord_root) x
    ];

// 2D-Rippenstreifen bei Spannweite y (ohne Löcher, intersected mit Profil)
// Zweite Richtung um rib_spacing/2 versetzt → Rippen alle 20mm an der Nase
module slice_ribs_2d(y) {
    c = elliptic_chord(y);
    for (params = [[rib_angle, 0], [-rib_angle, rib_spacing/2]]) {
        positions = _rib_x_positions(y, params[0], params[1]);
        intersection() {
            slice_profile_2d(y);
            for (x = positions)
                translate([x - rib_apparent_w/2, -30])
                    square([rib_apparent_w, 60]);
        }
    }
}

// === Komplette 2D-Scheibe bei Spannweite y ===
// Hier wird alles in 2D zusammengebaut.

// Profil bei Spannweite y (massiv, mit Grooves wo chord >= 80mm)
module slice_profile_2d(y) {
    c = elliptic_chord(y);
    airfoil_grooved_2d(wing_naca, c, groove_inset = groove_inset);
}

// Hülle bei Spannweite y (wall dick)
module slice_shell_2d(y) {
    c = elliptic_chord(y);
    difference() {
        slice_profile_2d(y);
        if (c > wall * 3)
            offset(r = -wall)
                slice_profile_2d(y);
    }
}

// Erleichterungsloch: offset(+r) offset(-r) → abgerundete Ecken
module _hole_2d(naca, chord, x_start, x_end, inset) {
    intersection() {
        translate([x_start, -30])
            square([x_end - x_start, 60]);
        offset(r = rib_inset_r) offset(r = -rib_inset_r)
            intersection() {
                offset(r = -inset)
                    airfoil_2d(naca, chord);
                translate([x_start, -30])
                    square([x_end - x_start, 60]);
            }
    }
}

// Erleichterungslöcher bei Spannweite y
// chord ≥ 80mm: 3 Löcher (Stege unter Filament-Nuten)
// chord ≥ 30mm: 1 Loch (Steg bei 50%)
// chord < 30mm: massiv
module slice_rib_holes_2d(y) {
    c = elliptic_chord(y);
    steg_w = steg_w_root * c / chord_root;
    nose_start = 13 * c / chord_root;
    inset = max(rib_inset_min, rib_inset_root * c / chord_root);
    groove_min_chord = 2 * groove_inset;

    if (c >= groove_min_chord) {
        s1 = groove_inset;
        s2 = c - groove_inset;
        _hole_2d(wing_naca, c, nose_start, s1 - steg_w/2, inset);
        _hole_2d(wing_naca, c, s1 + steg_w/2, s2 - steg_w/2, inset);
        _hole_2d(wing_naca, c, s2 + steg_w/2, c - nose_start, inset);
    } else if (c >= min_hole_chord) {
        s_mid = c * 0.5;
        _hole_2d(wing_naca, c, nose_start, s_mid - steg_w/2, inset);
        _hole_2d(wing_naca, c, s_mid + steg_w/2, c - nose_start, inset);
    }
}

// Basis-Slice: Hülle + Rippen mit Löchern (ohne Aileron-Logik)
module _slice_base_2d(y) {
    union() {
        slice_shell_2d(y);
        difference() {
            slice_ribs_2d(y);
            slice_rib_holes_2d(y);
        }
    }
}

// Komplette Scheibe mit Aileron-Logik
// gap/2 Clearance auf jeder Seite → zusammen aileron_gap Spalt
module slice_2d(y, part = "wing") {
    zone = aileron_zone(y);
    g = aileron_gap / 2;

    if (part == "wing") {
        // === Flügel-Teil ===
        if (zone == "none") {
            _slice_base_2d(y);
        } else if (zone == "closure_wing") {
            // Abschlusswand Flügel: Basis + massiv hinter Scharnier + Rückwand
            union() {
                _slice_base_2d(y);
                _clip_rear_vertical_2d(y)
                    slice_profile_2d(y);
                _hinge_wall_2d(y);
            }
        } else if (zone == "gap" || zone == "aileron" || zone == "closure_aileron") {
            // Vor Scharnier (mit Spalt) + Rückwand
            union() {
                _clip_front_2d(y, g) _slice_base_2d(y);
                _hinge_wall_2d(y);
            }
        }
    } else {
        // === Querruder-Teil ===
        if (zone == "closure_aileron") {
            // Abschlusswand Ruder: massiv hinter Bevel (schräg, kein Spalt)
            _clip_rear_bevel_2d(y ) slice_profile_2d(y);
        } else if (zone == "aileron") {
            // Querruder: Basis hinter Keil-Linie (schräg, mit Spalt) + schräge Vorderwand
            union() {
                _clip_rear_bevel_2d(y ) _slice_base_2d(y);
                _bevel_wall_2d(y);
            }
        }
        // zone == "none", "closure_wing", "gap" → nichts
    }
}

// === Flügel: Scheiben stapeln ===
module wing(y_start = 0, y_end = half_span) {
    n = floor((y_end - y_start) / step);
    for (i = [0 : n - 1]) {
        y = y_start + i * step;
        c = elliptic_chord(y);
        translate([le_offset(y), v_offset(y), y])
            linear_extrude(height = step)
                translate([sweep_ref * c, 0])
                    rotate([0, 0, twist(y)])
                        translate([-sweep_ref * c, 0])
                            slice_2d(y, "wing");
    }
}

// === Querruder: Scheiben stapeln ===
module aileron(y_start = aileron_y1 - aileron_gap, y_end = aileron_y2 + aileron_gap) {
    n = floor((y_end - y_start) / step);
    for (i = [0 : n - 1]) {
        y = y_start + i * step;
        c = elliptic_chord(y);
        translate([le_offset(y), v_offset(y), y])
            linear_extrude(height = step)
                translate([sweep_ref * c, 0])
                    rotate([0, 0, twist(y)])
                        translate([-sweep_ref * c, 0])
                            slice_2d(y, "aileron");
    }
}

// === Segmente (druckfertig, auf Z=0 verschoben) ===
module wing_segment(z_start, z_end) {
    translate([0, 0, -z_start])
        wing(z_start, z_end);
}

module aileron_part(z_start = aileron_y1 - aileron_gap, z_end = aileron_y2 + aileron_gap) {
    translate([0, 0, -z_start])
        aileron(z_start, z_end);
}

// === Optionale lokale Vorschau (nur für Selbsttest) ===
module elliptic_wing_preview() {
    $fn = $preview ? 24 : 64;                         // Kreisauflösung Preview/Render

    wing_naca       = [0.04, 0.4, 0.15];             // Profil: NACA 4415
    chord_root      = 180;                            // Wurzeltiefe [mm]
    half_span       = 600;                            // Halbspannweite [mm]
    step            = $preview ? 5 : 0.2;            // Slice-Dicke [mm]
    tip_min         = 5;                              // minimale Tiefe am Tip [mm]

    wall            = 0.4;                            // Hüllenwandstärke [mm]
    rib_wall        = 0.8;                            // Rippenstärke [mm]
    rib_angle       = 45;                             // Rippenwinkel [°]
    rib_spacing     = 40;                             // Rippenabstand [mm]
    rib_inset_root  = 5;                              // Lochrand an Wurzel [mm]
    rib_inset_min   = 2;                              // minimaler Lochrand [mm]
    rib_inset_r     = 1;                              // Lochverrundung [mm]
    steg_w_root     = 7;                              // Stegbreite an Wurzel [mm]
    min_hole_chord  = 30;                             // unterhalb keine Erleichterungslöcher [mm]

    v_angle         = 3;                              // V-Form [°]
    washout         = 3;                              // Schränkung am Tip [°]
    washout_start   = 0;                              // Beginn Schränkung [mm]
    sweep_ref       = 0.30;                           // Referenzlinie als Chord-Anteil

    aileron_hinge_pct = 0.79;                         // Scharnierposition am Innenpunkt als Chord-Anteil
    aileron_hinge_sweep = -8.2;                       // Scharnier-Sweep [°], 0° = quer zur Flugrichtung
    aileron_gap       = 0.8;                          // Ruderspalt [mm]
    aileron_bevel     = 30;                           // Keilwinkel an Scharnierkante [°]

    groove_inset      = 40;                           // Nutabstand von Nase/Endleiste [mm]

    _seg_unit         = round(half_span / 4.5 / step) * step;  // Basis-Segmentlänge [mm]
    aileron_y1        = 2 * _seg_unit;                // Ruderbeginn entlang Spannweite [mm]
    aileron_y2        = 4 * _seg_unit;                // Ruderende entlang Spannweite [mm]
    segment_bounds    = [
        0,                                             // Segment 1 Start
        1 * _seg_unit,                                 // Segmentgrenze 1
        2 * _seg_unit - aileron_gap,                   // vor Ruderspalt
        3 * _seg_unit,                                 // Segmentgrenze 3
        4 * _seg_unit + aileron_gap/2,                 // nach Ruderspalt
        half_span                                       // Tip/letzte Grenze
    ];

    wing();
}

// Für direkten Test in dieser Datei einkommentieren:
// elliptic_wing_preview();
