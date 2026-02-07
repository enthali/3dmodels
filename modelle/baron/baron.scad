// baron.scad – RC-Modellflugzeug "Baron"
// Inspiriert von 1920er Schulterdecker-Flugzeugen
// Zielmaschine: FlashForge Adventurer 5M (220×220×220 mm)
// Spannweite: ~1000 mm (mehrteilig gedruckt)
//
// Koordinatensystem:
//   X = Längsachse (Nase → Heck)
//   Y = Querachse (links → rechts, Spannweite)
//   Z = Hochachse (unten → oben)

use <../../lib/airfoil.scad>
use <../../lib/connectors.scad>

// ============================================================
// HAUPTPARAMETER
// ============================================================

// --- Gesamtmaße ---
wingspan       = 1000;  // [mm] Gesamtspannweite
fuselage_length = 700;  // [mm] Rumpflänge
fuselage_width  = 80;   // [mm] Rumpfbreite (max)
fuselage_height = 90;   // [mm] Rumpfhöhe (max)

// --- Flügel ---
wing_chord_root = 180;  // [mm] Flügeltiefe an der Wurzel
wing_chord_tip  = 130;  // [mm] Flügeltiefe an der Spitze
wing_thickness  = 0.15; // NACA Dicke (15%)
wing_camber     = 0.04; // NACA Wölbung (4%)
wing_camber_pos = 0.4;  // NACA Wölbungsposition (40%)
wing_naca       = [wing_camber, wing_camber_pos, wing_thickness]; // NACA 4415
wing_dihedral   = 3;    // [°] V-Stellung
wing_offset_x   = 150;  // [mm] Flügelvorderkante ab Nase
wing_offset_z   = 70;   // [mm] Flügel-Höhe (Schulterdecker!)

// --- Leitwerk ---
htail_span      = 300;  // [mm] Höhenleitwerk Spannweite
htail_chord     = 100;  // [mm] Höhenleitwerk Tiefe
htail_naca      = [0.00, 0.0, 0.09]; // NACA 0009 symmetrisch
vtail_height    = 120;  // [mm] Seitenleitwerk Höhe
vtail_chord     = 110;  // [mm] Seitenleitwerk Tiefe
vtail_naca      = [0.00, 0.0, 0.09]; // NACA 0009

// --- Fahrwerk ---
gear_height     = 100;  // [mm] Fahrwerkshöhe
gear_spread     = 200;  // [mm] Radabstand
wheel_d         = 50;   // [mm] Raddurchmesser
wheel_w         = 15;   // [mm] Radbreite

// --- Motorsektion ---
nose_length     = 80;   // [mm] Motorhaube Länge
nose_diameter   = 65;   // [mm] Motorhaube Durchmesser

// --- Druckparameter ---
wall            = 1.6;  // [mm] Wandstärke (4 Perimeter × 0.4mm)
print_bed       = 210;  // [mm] Nutzbare Druckfläche (etwas Margin)
spar_d          = 6;    // [mm] Carbonrohr-Durchmesser (Flügelholm)
spar_d_fuse     = 8;    // [mm] Carbonrohr für Rumpfholm

// --- Auflösung ---
$fn = $preview ? 32 : 128;

// ============================================================
// BERECHNETE WERTE
// ============================================================

// Flügelsegmente: Halbspannweite / druckbare Länge
half_span       = (wingspan - fuselage_width) / 2;
wing_segments   = ceil(half_span / print_bed);
segment_span    = half_span / wing_segments;

// Rumpfsegmente
fuse_segments   = ceil(fuselage_length / print_bed);
fuse_seg_len    = fuselage_length / fuse_segments;

echo(str("=== BARON Build Info ==="));
echo(str("Halbspannweite: ", half_span, " mm"));
echo(str("Flügelsegmente pro Seite: ", wing_segments, " (je ", segment_span, " mm)"));
echo(str("Rumpfsegmente: ", fuse_segments, " (je ", fuse_seg_len, " mm)"));
echo(str("Druckbare Segmentlänge: ", print_bed, " mm"));

// ============================================================
// MODULE
// ============================================================

// --- Rumpf-Querschnitt (abgerundetes Rechteck / Oval) ---
module fuselage_cross_section(w, h) {
    scale([w/2, h/2])
        circle(d = 2, $fn = $preview ? 32 : 64);
}

// --- Rumpfsegment ---
// pos = Position entlang der Rumpfachse (0 = Nase, 1 = Heck)
module fuselage_segment(seg_index) {
    start_x = seg_index * fuse_seg_len;
    end_x   = (seg_index + 1) * fuse_seg_len;

    // Rumpfkontur: vorne spitz, Mitte breit, hinten verjüngt
    function fuse_width(x) =
        let(t = x / fuselage_length)
        (t < 0.15)
            ? fuselage_width * sin(t / 0.15 * 90)      // Nase: schnell aufweiten
            : (t < 0.6)
                ? fuselage_width                         // Mitte: volle Breite
                : fuselage_width * (1 - pow((t - 0.6) / 0.4, 1.5) * 0.6); // Heck: sanft verjüngen

    function fuse_height(x) =
        let(t = x / fuselage_length)
        (t < 0.15)
            ? fuselage_height * sin(t / 0.15 * 90)
            : (t < 0.6)
                ? fuselage_height
                : fuselage_height * (1 - pow((t - 0.6) / 0.4, 1.5) * 0.5);

    steps = 20;
    step_len = fuse_seg_len / steps;

    // Hohler Rumpf aus Schnitten
    difference() {
        // Äußere Hülle
        for (i = [0:steps-1]) {
            x0 = start_x + i * step_len;
            x1 = x0 + step_len;
            w0 = fuse_width(x0);
            h0 = fuse_height(x0);
            w1 = fuse_width(x1);
            h1 = fuse_height(x1);

            hull() {
                translate([x0, 0, 0])
                    rotate([0, 90, 0])
                        linear_extrude(0.01)
                            fuselage_cross_section(w0, h0);
                translate([x1, 0, 0])
                    rotate([0, 90, 0])
                        linear_extrude(0.01)
                            fuselage_cross_section(w1, h1);
            }
        }

        // Innenraum aushöhlen
        for (i = [0:steps-1]) {
            x0 = start_x + i * step_len;
            x1 = x0 + step_len;
            w0 = fuse_width(x0) - 2 * wall;
            h0 = fuse_height(x0) - 2 * wall;
            w1 = fuse_width(x1) - 2 * wall;
            h1 = fuse_height(x1) - 2 * wall;

            if (w0 > 0 && h0 > 0 && w1 > 0 && h1 > 0) {
                hull() {
                    translate([x0 - 0.1, 0, 0])
                        rotate([0, 90, 0])
                            linear_extrude(0.01)
                                fuselage_cross_section(w0, h0);
                    translate([x1 + 0.1, 0, 0])
                        rotate([0, 90, 0])
                            linear_extrude(0.01)
                                fuselage_cross_section(w1, h1);
                }
            }
        }
    }
}

// --- Flügelsegment ---
// seg = Segmentnummer (0 = Wurzel, wing_segments-1 = Spitze)
// side = 1 (rechts) oder -1 (links)
module wing_segment(seg, side = 1) {
    y_start = seg * segment_span;
    y_end   = (seg + 1) * segment_span;

    // Chord interpolation (linear taper)
    function chord_at(y) =
        wing_chord_root + (wing_chord_tip - wing_chord_root) * (y / half_span);

    steps = 10;
    step_span = segment_span / steps;

    // Flügel mit Dihedral
    rotate([0, 0, 0])
    translate([wing_offset_x, side * (fuselage_width/2 + y_start), wing_offset_z])
    rotate([side * wing_dihedral, 0, 0])
    difference() {
        // Äußere Flügelform
        for (i = [0:steps-1]) {
            y0 = i * step_span;
            y1 = (i + 1) * step_span;
            c0 = chord_at(y_start + y0);
            c1 = chord_at(y_start + y1);

            hull() {
                translate([0, side * y0, 0])
                    rotate([90, 0, 0])
                        linear_extrude(0.01)
                            airfoil_2d(wing_naca, c0);
                translate([0, side * y1, 0])
                    rotate([90, 0, 0])
                        linear_extrude(0.01)
                            airfoil_2d(wing_naca, c1);
            }
        }

        // Holmkanal für Carbonrohr
        translate([wing_chord_root * 0.3, side * segment_span / 2, 0])
            rotate([90, 0, 0])
                cylinder(d = spar_d + 0.4, h = segment_span + 2, center = true);
    }
}

// --- Höhenleitwerk ---
module horizontal_tail() {
    translate([fuselage_length - htail_chord, 0, fuselage_height * 0.3]) {
        for (side = [1, -1]) {
            hull() {
                translate([0, 0, 0])
                    rotate([90, 0, 0])
                        linear_extrude(0.01)
                            airfoil_2d(htail_naca, htail_chord);
                translate([htail_chord * 0.1, side * htail_span/2, 0])
                    rotate([90, 0, 0])
                        linear_extrude(0.01)
                            airfoil_2d(htail_naca, htail_chord * 0.7);
            }
        }
    }
}

// --- Seitenleitwerk ---
module vertical_tail() {
    translate([fuselage_length - vtail_chord, 0, fuselage_height * 0.3])
        rotate([0, 0, 0])
        hull() {
            rotate([90, 0, 0])
                linear_extrude(0.01)
                    airfoil_2d(vtail_naca, vtail_chord);
            translate([vtail_chord * 0.15, 0, vtail_height])
                rotate([90, 0, 0])
                    linear_extrude(0.01)
                        airfoil_2d(vtail_naca, vtail_chord * 0.5);
        }
}

// --- Motorhaube ---
module engine_cowl() {
    difference() {
        // Äußere Form
        hull() {
            translate([0, 0, 0])
                rotate([0, 90, 0])
                    cylinder(d = nose_diameter, h = 1);
            translate([nose_length, 0, fuselage_height * 0.05])
                rotate([0, 90, 0])
                    linear_extrude(0.01)
                        fuselage_cross_section(fuselage_width, fuselage_height);
        }
        // Innen hohl (für Motor)
        hull() {
            translate([-1, 0, 0])
                rotate([0, 90, 0])
                    cylinder(d = nose_diameter - 2*wall, h = 1);
            translate([nose_length - wall, 0, fuselage_height * 0.05])
                rotate([0, 90, 0])
                    linear_extrude(0.01)
                        fuselage_cross_section(fuselage_width - 2*wall, fuselage_height - 2*wall);
        }
    }
}

// --- Fahrwerk (vereinfacht) ---
module landing_gear() {
    // Fahrwerksbeine
    for (side = [1, -1]) {
        translate([wing_offset_x + wing_chord_root * 0.35, side * gear_spread/2, 0]) {
            // Bein
            color("DarkGray")
            rotate([0, 5 * side, 0])
                cylinder(d = 4, h = gear_height + wing_offset_z);
            // Rad
            color("DimGray")
            translate([0, 0, -wheel_d/2])
                rotate([90, 0, 0])
                    cylinder(d = wheel_d, h = wheel_w, center = true);
        }
    }
}


// ============================================================
// ZUSAMMENBAU – Gesamtansicht
// ============================================================

module baron_complete() {
    color("Gold", 0.9) {
        // Rumpfsegmente
        for (i = [0:fuse_segments-1]) {
            fuselage_segment(i);
        }
    }

    // Motorhaube
    color("DarkRed", 0.9)
        engine_cowl();

    // Flügel (beide Seiten)
    color("Khaki", 0.9) {
        for (seg = [0:wing_segments-1]) {
            wing_segment(seg, 1);   // rechts
            wing_segment(seg, -1);  // links
        }
    }

    // Leitwerk
    color("Khaki", 0.9) {
        horizontal_tail();
        vertical_tail();
    }

    // Fahrwerk
    landing_gear();
}

// ============================================================
// RENDERING
// ============================================================

// Gesamtansicht (Standard)
baron_complete();

// Einzelteile zum Drucken: auskommentieren und jeweils aktivieren
// fuselage_segment(0);    // Rumpf Segment 1 (Nase)
// fuselage_segment(1);    // Rumpf Segment 2
// fuselage_segment(2);    // Rumpf Segment 3
// wing_segment(0, 1);     // Flügel rechts, Segment 1 (Wurzel)
// wing_segment(1, 1);     // Flügel rechts, Segment 2 (Spitze)
// horizontal_tail();      // Höhenleitwerk
// vertical_tail();        // Seitenleitwerk
// engine_cowl();          // Motorhaube
