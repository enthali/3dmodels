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
tail_width      = 8;                  // [mm] Breite der Endleiste
tail_r          = 1.9;                  // [mm] Endleisten-Kreis Radius
tail_cx         = 235.8;                // [mm] Endleisten-Kreis X
tail_cy         = 1.8;                  // [mm] Endleisten-Kreis Y

$fn = $preview ? 32 : 128;

// --- Gekreuzte Rippen Parameter ---
rib_spacing     = 25;                 // [mm] Abstand zwischen Rippen
rib_offset      = tan(rib_angle) * chord;
rib_length      = chord / cos(rib_angle);
rib_count       = floor((half_span + rib_offset) / rib_spacing);

// --- Flügelblock (10cm Segment) ---
intersection() {
    // Profilvolumen
    linear_extrude(height = seg_height)
        airfoil_2d(wing_naca, chord);

    // Gekreuzte Rippen
    union() {
        // Wurzelrippe (massiv, 3 Layer)
        linear_extrude(height = root_rib_height)
            airfoil_2d(wing_naca, chord);

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
nose_gap        = 3;                  // [mm] Abstand LE bis Kreis
nose_cx         = nose_gap + nose_r;  // Kreis-Mittelpunkt X

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
