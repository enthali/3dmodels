// wing_segment.scad – Flügelsegment mit gekreuzten Rippen

use <../../lib/airfoil.scad>

// --- Profil ---
wing_naca       = [0.04, 0.4, 0.15];  // NACA 4415
chord           = 150;                 // [mm] Profiltiefe
half_span       = 500;                // [mm] Halbspannweite
seg_height      = 100;                // [mm] Segmenthöhe

// --- Wandstärken ---
wall            = 0.4;                // [mm] Hüllenwandstärke (1× Düse)
rib_wall        = 0.8;                // [mm] Rippenstärke (2× Düse)
root_rib_height = 0.4;                // [mm] Wurzelrippe (2 Layer)

// --- Rippen ---
rib_angle       = 45;                 // [°] Winkel der gekreuzten Rippen
rib_spacing     = 30;                 // [mm] Abstand zwischen Rippen
rib_inset       = 4;                  // [mm] Rippen-Abstand zur Hülle
rib_inset_r     = 3;                  // [mm] Verrundung der Erleichterungslöcher

// --- Holm (Kohlefaser-Rohr) ---
spar_d          = 6;                  // [mm] Holm-Durchmesser
spar_tol        = 0.2;                // [mm] Toleranz für Holmbohrung
spar_pos        = 0.30;               // [%] Position (30% chord)
spar_box_w      = 16;                 // [mm] Holmsteg-Breite

// --- Zweiter Steg ---
steg2_pos       = 0.60;               // [%] Position (60% chord)
steg2_w         = 12;                  // [mm] Steg-Breite

$fn = $preview ? 32 : 128;

// --- Berechnete Werte ---
rib_offset      = tan(rib_angle) * chord;
rib_length      = chord / cos(rib_angle);
rib_count       = floor((half_span + rib_offset) / rib_spacing);
spar_x          = spar_pos * chord;
steg2_x         = steg2_pos * chord;
nose_cx         = 13;                  // [mm] Beginn vorderes Loch (nach Nasenbereich)
tail_cx         = chord - 10;          // [mm] Ende hinteres Loch (vor Endleiste)

// --- Gelochte Rippe (2D Modul) ---
module rib_2d() {
    difference() {
        airfoil_2d(wing_naca, chord);

        // Vorderes Erleichterungsloch (Nase bis Holm)
        offset(r = rib_inset_r) offset(r = -rib_inset_r)
            intersection() {
                offset(r = -rib_inset)
                    airfoil_2d(wing_naca, chord);
                translate([nose_cx, -30])
                    square([spar_x - spar_box_w/2 - nose_cx, 60]);
            }

        // Mittleres Erleichterungsloch (Holm bis Steg 2)
        offset(r = rib_inset_r) offset(r = -rib_inset_r)
            intersection() {
                offset(r = -rib_inset)
                    airfoil_2d(wing_naca, chord);
                translate([spar_x + spar_box_w/2, -30])
                    square([steg2_x - steg2_w/2 - (spar_x + spar_box_w/2), 60]);
            }

        // Hinteres Erleichterungsloch (Steg 2 bis Endleiste)
        offset(r = rib_inset_r) offset(r = -rib_inset_r)
            intersection() {
                offset(r = -rib_inset)
                    airfoil_2d(wing_naca, chord);
                translate([steg2_x + steg2_w/2, -30])
                    square([tail_cx - (steg2_x + steg2_w/2), 60]);
            }

        // Holmbohrung
        translate([spar_x, 0])
            circle(d = spar_d + spar_tol);
    }
}

// --- Wurzelrippe (massiv, bündig mit Hülle, mit Holmbohrung) ---

linear_extrude(height = root_rib_height)
    rib_2d();

// --- Rippenblock (10cm Segment) ---
intersection() {
    // Profil extrudiert
    linear_extrude(height = seg_height)
        rib_2d();

    // Gekreuzte Rippen
    union() {
        // Rippen Richtung 1
        for (i = [0 : rib_count])
            translate([0, -10, i * rib_spacing - rib_offset])
                rotate([0, -rib_angle, 0])
                    cube([rib_length, 40, rib_wall]);

        // Rippen Richtung 2
        for (i = [0 : rib_count])
            translate([0, -10, i * rib_spacing])
                rotate([0, rib_angle, 0])
                    cube([rib_length, 40, rib_wall]);
    }
}


// Nasenleiste und Endleiste entfallen

// --- Hülle (dünne Profilschale) ---
linear_extrude(height = seg_height)
    difference() {
        airfoil_2d(wing_naca, chord);
        offset(r = -wall)
            airfoil_2d(wing_naca, chord);
    }