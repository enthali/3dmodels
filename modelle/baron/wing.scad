// wing.scad – Flügel für den Baron
// Linker Halbflügel, senkrecht stehend (Vase-Mode Druck)
// Profil unten = Wurzel, oben = Spitze
// V-Form: 3.5° nach außen geneigt

use <../../lib/airfoil.scad>

wing_naca       = [0.04, 0.4, 0.15];  // NACA 4415
chord_root      = 250;                 // [mm] Wurzeltiefe
chord_tip       = 200;                 // [mm] Spitze (20 cm)
half_span       = 500;                 // [mm] Halbspannweite
v_angle         = 3.0;                 // [°] V-Form pro Seite (7° total)

// Holm-Parameter
spar_d          = 6;                   // [mm] Carbonrohr Hauptholm
spar_pos        = 0.30;               // 30% Flügeltiefe
spar_len        = 505;                  // Holm Länge
span_hight_pos  = 23.5;                 // Lages des Holm über der Profilsehene an der Wurzelrippe
rear_spar_d     = 4;                   // [mm] hinterer Holm
rear_spar_pos   = 0.70;               // 70% Flügeltiefe
rear_spar_len   = 250;                // [mm] hinterer Holm kürzer

$fn = $preview ? 32 : 128;

// Profilhöhe bei 30% Tiefe (NACA 4415): ca. 37.5 mm bei 250er Chord
// Holm läuft schräg: oben-innen nach unten-außen
spar_z_root     = chord_root * 0.10;   // [mm] Holm-Höhe an Wurzel (obere Hälfte)
spar_z_tip      = -chord_tip * 0.03;   // [mm] Holm-Höhe an Spitze (nahe Unterseite)

module half_wing() {
    difference() {
        // Flügel mit V-Form: schräger Extrude via Scherung
        // Wurzel bleibt flach bei Z=0, Spitze wandert um tan(3.5°)*500 ≈ 30.6mm in Y
        multmatrix([
            [1, 0, 0,            0],
            [0, 1, tan(v_angle), 0],
            [0, 0, 1,            0]
        ])
        linear_extrude(height = half_span, scale = chord_tip / chord_root)
            airfoil_2d(wing_naca, chord_root);

        // Hauptholm-Kanal (senkrecht, gerade nach oben)
        translate([chord_root * spar_pos, span_hight_pos, -1])
            cylinder(d = spar_d + 0.4, h = spar_len , $fn = 32);

        // Hinterer Holm-Kanal (senkrecht, kürzer)
        translate([chord_root * rear_spar_pos, 15, -1])
            cylinder(d = rear_spar_d + 0.4, h = rear_spar_len , $fn = 32);
    }
}

half_wing();
