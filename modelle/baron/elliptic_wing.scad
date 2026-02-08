// elliptic_wing.scad – Elliptischer Halbflügel (DC-3 Style)
// Elliptische Tiefenverteilung: c(y) = c_root * sqrt(1 - (y/b)²)
// 30% chord auf gerader Linie (Pfeilungsreferenz)
// Verstärkung: 4× Filament-Nuten auf Profiloberfläche (statt CF-Holm)

use <../../lib/airfoil.scad>
use <../../lib/grooves.scad>

// --- Profil ---
wing_naca       = [0.04, 0.4, 0.15];  // NACA 4415
chord_root      = 180;                 // [mm] Wurzeltiefe
half_span       = 600;                 // [mm] Halbspannweite (60cm)
step            = $preview ? 5 : 0.4; // [mm] Slice = Layer-Höhe (0.2mm)
tip_min         = 5;                  // [mm] minimale Profiltiefe an Spitze

// --- Wandstärken ---
wall            = 0.4;                // [mm] Hüllenwandstärke (1× Düse)
rib_wall        = 0.8;                // [mm] Rippenstärke (2× Düse)

// --- Rippen ---
rib_angle       = 45;                 // [°] Winkel der Kreuzrippen
rib_spacing     = 40;                 // [mm] Abstand zwischen Rippen
rib_inset_root  = 5;                  // [mm] Erleichterungsloch-Abstand zur Hülle (an Wurzel)
rib_inset_min   = 2;                  // [mm] Minimum-Rand (darunter wird Rippe massiv)
rib_inset_r     = 1;                  // [mm] Verrundung der Löcher
steg_w_root     = 7;                  // [mm] Stegbreite an der Wurzel (skaliert mit Chord)
min_hole_chord  = 30;                 // [mm] Chord unter dem keine Löcher mehr

// --- V-Form ---
v_angle         = 0;                  // [°] V-Form deaktiviert (Keil-Lösung später)

// --- Schränkung (Washout) ---
washout         = 3;                  // [°] max. Schränkung am Tip (Nase runter)
washout_start   = 0;                // [mm] Beginn der Schränkung (ab Segment 2)

// --- Pfeilung ---
sweep_ref       = 0.30;              // 30% chord – Referenzlinie für Pfeilung

// Filament-Nuten: Werte aus lib/grooves.scad hier lokal (use importiert keine Variablen!)
groove_inset     = 40;                // [mm] Abstand Nut von Nase/Endleiste
groove_min_chord = 2 * groove_inset;  // [mm] Nuten nur bei chord ≥ 80mm

$fn = $preview ? 24 : 64;

// === Elliptische Profiltiefe ===
function elliptic_chord(y) =
    max(tip_min, chord_root * sqrt(1 - pow(min(y, half_span) / half_span, 2)));

// Leading-Edge Versatz: 30% aller Chords auf einer senkrechten Linie
function le_offset(y) = sweep_ref * (chord_root - elliptic_chord(y));

// V-Form Versatz: Y steigt mit Spannweite
function v_offset(y) = tan(v_angle) * y;

// Schränkung: linear von 0° (washout_start) bis +washout° (Tip), Nase runter
function twist(y) =
    y <= washout_start ? 0 :
    washout * (y - washout_start) / (half_span - washout_start);

// === Berechnete Werte ===
n_steps         = floor(half_span / step);
rib_offset_z    = tan(rib_angle) * chord_root;
rib_length      = chord_root * 2 / cos(rib_angle);
rib_count       = floor((half_span + rib_offset_z) / rib_spacing);

// === Module ===

// Erleichterungsloch: offset(r=+r) offset(r=-r) → abgerundete Ecken
// intersection clippt zurück auf Steg-Grenzen (sonst frisst offset den Steg)
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

// 2D-Erleichterungslöcher für eine Rippe bei gegebener Chord
// chord ≥ 80mm: 3 Löcher (Nase | Steg1 @ 40mm | Mitte | Steg2 @ chord-40mm | Heck)
// chord < 80mm: 1 Loch (Nase | Steg @ 50% | Heck) — Steg unter den Grooves
// chord < min_hole_chord: nichts (massiv)
module rib_hollow_2d(naca, chord) {
    steg_w = steg_w_root * chord / chord_root;
    nose_start = 13 * chord / chord_root;  // skaliert mit Chord
    inset = max(rib_inset_min, rib_inset_root * chord / chord_root);

    if (chord >= groove_min_chord) {
        // 3 Löcher: Stege bei groove_inset und chord-groove_inset
        s1 = groove_inset;
        s2 = chord - groove_inset;
        // Vorderes Loch
        _hole_2d(naca, chord, nose_start, s1 - steg_w/2, inset);
        // Mittleres Loch
        _hole_2d(naca, chord, s1 + steg_w/2, s2 - steg_w/2, inset);
        // Hinteres Loch
        _hole_2d(naca, chord, s2 + steg_w/2, chord - nose_start, inset);
    } else if (chord >= min_hole_chord) {
        // 1 Loch: Steg bei 50%
        s_mid = chord * 0.5;
        _hole_2d(naca, chord, nose_start, s_mid - steg_w/2, inset);
        _hole_2d(naca, chord, s_mid + steg_w/2, chord - nose_start, inset);
    }
    // else: massiv, keine Löcher
}

// Elliptischer Hollow-Körper (zum Subtrahieren von Kreuzrippen)
module elliptic_hollow() {
    for (i = [0 : n_steps - 1]) {
        y = i * step;
        c1 = elliptic_chord(y);
        if (c1 >= min_hole_chord)
            translate([le_offset(y), v_offset(y), y])
                linear_extrude(height = step)
                    translate([sweep_ref * c1, 0])
                        rotate([0, 0, twist(y)])
                            translate([-sweep_ref * c1, 0])
                                rib_hollow_2d(wing_naca, c1);
    }
}

// Elliptischer Vollkörper (mit Filament-Nuten im Profil)
module elliptic_solid() {
    for (i = [0 : n_steps - 1]) {
        y = i * step;
        c1 = elliptic_chord(y);
        // LE-Offset + V-Form + Spannweite, Profil um 30% gedreht (Washout)
        translate([le_offset(y), v_offset(y), y])
            linear_extrude(height = step)
                translate([sweep_ref * c1, 0])
                    rotate([0, 0, twist(y)])
                        translate([-sweep_ref * c1, 0])
                            airfoil_grooved_2d(wing_naca, c1);
    }
}

// Elliptischer Innenkörper (grooved + offset → gleichmäßige Wand um Grooves)
module elliptic_inner() {
    for (i = [0 : n_steps - 1]) {
        y = i * step;
        c1 = elliptic_chord(y);
        if (c1 > wall * 3)
            translate([le_offset(y), v_offset(y), y])
                linear_extrude(height = step)
                    translate([sweep_ref * c1, 0])
                        rotate([0, 0, twist(y)])
                            translate([-sweep_ref * c1, 0])
                                offset(r = -wall) airfoil_grooved_2d(wing_naca, c1);
    }
}

// === Haupt-Modul: Halbflügel-Segment ===
// z_start/z_end: Spannweiten-Bereich [mm] (0 = Wurzel)
// Das Segment wird auf Z=0 verschoben (druckfertig)
module half_wing_segment(z_start = 0, z_end = half_span) {
    translate([0, 0, -z_start])
    intersection() {
        // Schneidquader für das Segment
        translate([-50, -50, z_start])
            cube([chord_root + 100, 100, z_end - z_start]);

        // Ganzer Halbflügel
        difference() {
            union() {
                // Kreuzrippen (konform zur Ellipse, mit Erleichterungslöchern)
                difference() {
                    intersection() {
                        elliptic_solid();
                        union() {
                            for (i = [0 : rib_count])
                                translate([0, -30, i * rib_spacing - rib_offset_z])
                                    rotate([0, -rib_angle, 0])
                                        cube([rib_length, 60, rib_wall]);
                            for (i = [0 : rib_count + 1])
                                translate([0, -30, i * rib_spacing - rib_offset_z + rib_spacing/2])
                                    rotate([0, rib_angle, 0])
                                        cube([rib_length, 60, rib_wall]);
                        }
                    }
                    elliptic_hollow();
                }
                // Hülle (Nuten im Profil, Inner ohne Nuten → Nut bleibt offen)
                difference() {
                    elliptic_solid();
                    elliptic_inner();
                }
            }
        }
    }
}

// --- Vorschau ---
half_wing_segment(0, half_span);
