// elliptic_wing.scad – Experimenteller elliptischer Halbflügel (DC-3 Style)
// Elliptische Tiefenverteilung: c(y) = c_root * sqrt(1 - (y/b)²)
// Holm bei 30% chord bleibt auf gerader Linie

use <../../lib/airfoil.scad>

// --- Profil ---
wing_naca       = [0.04, 0.4, 0.15];  // NACA 4415
chord_root      = 180;                 // [mm] Wurzeltiefe
half_span       = 600;                 // [mm] Halbspannweite (60cm)
step            = $preview ? 20 : 5;   // [mm] Slice-Auflösung
tip_min         = 15;                  // [mm] minimale Profiltiefe an Spitze

// --- Wandstärken ---
wall            = 0.4;                // [mm] Hüllenwandstärke (1× Düse)
rib_wall        = 0.8;                // [mm] Rippenstärke (2× Düse)
root_rib_height = 0.4;                // [mm] Wurzelrippe

// --- Rippen ---
rib_angle       = 45;                 // [°] Winkel der Kreuzrippen
rib_spacing     = 40;                 // [mm] Abstand zwischen Rippen

// --- V-Form ---
v_angle         = 3.0;                // [°] V-Form pro Seite

// --- Holm ---
spar_d          = 6;                  // [mm] CF-Rohr Durchmesser
spar_tol        = 0.2;               // [mm] Toleranz
spar_pos        = 0.30;              // 30% chord
spar_y          = 16.3;              // [mm] Holm Y über Sehne (4mm unter Oberkante)
spar_len        = 310;               // [mm] Holm reicht bis ~50% Spannweite (V-Form-Limit)

$fn = $preview ? 24 : 64;

// === Elliptische Profiltiefe ===
function elliptic_chord(y) =
    max(tip_min, chord_root * sqrt(1 - pow(min(y, half_span) / half_span, 2)));

// Leading-Edge Versatz: 30% chord bleibt auf gerader Linie (für geraden Holm)
function le_offset(y) = (chord_root - elliptic_chord(y)) * spar_pos;

// V-Form Versatz: Y steigt mit Spannweite
function v_offset(y) = tan(v_angle) * y;

// === Berechnete Werte ===
n_steps         = floor(half_span / step);
rib_offset_z    = tan(rib_angle) * chord_root;
rib_length      = chord_root * 2 / cos(rib_angle);
rib_count       = floor((half_span + rib_offset_z) / rib_spacing);
spar_x          = spar_pos * chord_root;  // Holm X-Position (konstant)

// === Module ===

// Elliptischer Vollkörper (für Intersection mit Rippen)
module elliptic_solid() {
    for (i = [0 : n_steps - 1]) {
        y = i * step;
        c1 = elliptic_chord(y);
        c2 = elliptic_chord(y + step);
        hull() {
            translate([le_offset(y), v_offset(y), y])
                linear_extrude(height = 0.01)
                    airfoil_2d(wing_naca, c1);
            translate([le_offset(y + step), v_offset(y + step), y + step])
                linear_extrude(height = 0.01)
                    airfoil_2d(wing_naca, c2);
        }
    }
}

// Elliptischer Innenkörper (für Hüllen-Differenz)
module elliptic_inner() {
    for (i = [0 : n_steps - 1]) {
        y = i * step;
        c1 = elliptic_chord(y);
        c2 = elliptic_chord(y + step);
        if (c1 > wall * 3 && c2 > wall * 3)  // nur wenn Profil dick genug
        hull() {
            translate([le_offset(y), v_offset(y), y])
                linear_extrude(height = 0.01)
                    offset(r = -wall) airfoil_2d(wing_naca, c1);
            translate([le_offset(y + step), v_offset(y + step), y + step])
                linear_extrude(height = 0.01)
                    offset(r = -wall) airfoil_2d(wing_naca, c2);
        }
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
                // Wurzelrippe (nur wenn Segment bei Z=0 beginnt)
                if (z_start == 0)
                    linear_extrude(height = root_rib_height)
                        difference() {
                            airfoil_2d(wing_naca, chord_root);
                            translate([spar_x, spar_y]) circle(d = spar_d + spar_tol);
                        }

                // Kreuzrippen (konform zur Ellipse)
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

                // Hülle
                difference() {
                    elliptic_solid();
                    elliptic_inner();
                }
            }
            // Holm-Kanal (nur wenn im Segment-Bereich)
            if (z_start < spar_len)
                translate([spar_x, spar_y, -1])
                    cylinder(d = spar_d + spar_tol, h = spar_len + 2);
        }
    }
}

// --- Vorschau: ganzer Halbflügel ---
half_wing_segment(0, half_span);
