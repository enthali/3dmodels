// wing_segment.scad – Flügelsegment mit gekreuzten Rippen

use <../../lib/airfoil.scad>

// --- Parameter ---
wing_naca       = [0.04, 0.4, 0.15];  // NACA 4415
chord           = 250;                 // [mm] Profiltiefe
root_rib_height = 0.7;                // [mm] 3 Layer (0.3 + 0.2 + 0.2)
rib_angle       = 20;                 // [°] Winkel der gekreuzten Rippen
half_span       = 500;                // [mm] Halbspannweite
seg_height      = 100;                // [mm] Segmenthöhe (10 cm)
nose_r          = 10;                  // [mm] Nasenleisten-Radius
nose_gap        = 3;                  // [mm] Abstand LE bis Kreis
nose_cx         = nose_gap + nose_r;  // Kreis-Mittelpunkt X
tail_width      = 8;                  // [mm] Breite der Endleiste
tail_r          = 1.5;                  // [mm] Endleisten-Kreis Radius
tail_cx         = 240;                // [mm] Endleisten-Kreis X
tail_cy         = 1.3;                  // [mm] Endleisten-Kreis Y
wall            = 0.8;                // [mm] Hüllenwandstärke (2× Düse)
rib_inset       = 3;                  // [mm] Rippen-Abstand zur Hülle
rib_inset_r     = 2;                  // [mm] Verrundung der Innenkontur
spar_d          = 6;                  // [mm] Holm-Durchmesser (Kohlefaser)
spar_tol        = 0.2;                // [mm] Toleranz für Holmbohrung
spar_pos        = 0.30;               // [%] Holm-Position (30% chord)
spar_box_w      = 12;                 // [mm] Holmsteg-Breite
steg2_pos       = 0.60;               // [%] Zweiter Steg Position
steg2_w         = 8;                  // [mm] Zweiter Steg Breite

$fn = $preview ? 32 : 128;

// --- Gekreuzte Rippen Parameter ---
rib_spacing     = 25;                 // [mm] Abstand zwischen Rippen
rib_offset      = tan(rib_angle) * chord;
rib_length      = chord / cos(rib_angle);
rib_count       = floor((half_span + rib_offset) / rib_spacing);
spar_x          = spar_pos * chord;
steg2_x         = steg2_pos * chord;

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

// --- Vorschau: nur die gelochte Rippe ---
//rib_2d();

// --- Wurzelrippe (massiv, bündig mit Hülle, mit Holmbohrung) ---

linear_extrude(height = root_rib_height)
    difference() {
        airfoil_2d(wing_naca, chord);
        translate([spar_x, 0])
            circle(d = spar_d + spar_tol);
    }

// --- Rippenblock (10cm Segment) ---
intersection() {
    // Gelochtes Profil extrudiert
    linear_extrude(height = seg_height)
        rib_2d();

    // Gekreuzte Rippen
    union() {
        // Rippen Richtung 1
        for (i = [0 : rib_count])
            translate([0, -10, i * rib_spacing - rib_offset])
                rotate([0, -rib_angle, 0])
                    cube([rib_length, 40, 0.8]);

        // Rippen Richtung 2
        for (i = [0 : rib_count])
            translate([0, -10, i * rib_spacing])
                rotate([0, rib_angle, 0])
                    cube([rib_length, 40, 0.8]);
    }
}


// --- Nasenleiste (massiv) ---
linear_extrude(height = seg_height)
    intersection() {
        difference() {
            airfoil_2d(wing_naca, chord);
            translate([nose_cx, 2.6])
                circle(r = nose_r);
        }
        // Nur links vom Kreis-Mittelpunkt behalten
        translate([0, -20])
        rotate([0,0,10])
            square([nose_cx, 40]);
    }

// --- Endleiste (massiv, abgerundet) ---
linear_extrude(height = seg_height)
    intersection() {
        difference() {
            airfoil_2d(wing_naca, chord);
            translate([tail_cx, tail_cy])
                circle(r = tail_r);
        }
        // Nur rechts vom Kreis-Mittelpunkt behalten
        translate([tail_cx, -20])
            square([chord - tail_cx + 1, 40]);
    }

// Holmkasten entfällt – Holm ist in die Rippen integriert

// --- Hülle (dünne Profilschale) ---
linear_extrude(height = seg_height)
    difference() {
        airfoil_2d(wing_naca, chord);
        offset(r = -wall)
            airfoil_2d(wing_naca, chord);
    }