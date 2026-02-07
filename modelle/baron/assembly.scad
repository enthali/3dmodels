// assembly.scad – Baron Gesamtmodell (Zusammenbau)
// Importiert alle Einzelteile und positioniert sie.
//
// Koordinatensystem:
//   X = Längsachse (Nase → Heck)
//   Y = Querachse (links → rechts, Spannweite)
//   Z = Hochachse (unten → oben)

use <wing.scad>
// use <fuselage.scad>     // TODO
// use <tail.scad>         // TODO
// use <engine.scad>       // TODO
// use <landing_gear.scad> // TODO

// ============================================================
// PARAMETER (müssen mit Einzelteilen übereinstimmen)
// ============================================================

fuselage_width  = 80;    // [mm]
wing_offset_x   = 150;   // [mm] Flügelvorderkante ab Nase
wing_offset_z   = 70;    // [mm] Schulterdecker-Höhe
wing_x_rotate = 90;
wing_y_rotate = 0;
wing_z_rotate = 0;

// ============================================================
// ZUSAMMENBAU
// ============================================================

module baron() {
    // --- Flügel links ---
    // wing.scad: Profil in XY, extrudiert nach Z hoch
    // Assembly:  drehen damit Spannweite in Y geht, Profil-Oberseite nach Z+
    color("Khaki", 0.9)
    translate([wing_offset_x, 0, wing_offset_z])
        rotate([wing_x_rotate, wing_y_rotate, wing_z_rotate])       // Z (Spannweite) → Y+
                 half_wing();

    // --- Flügel Rechts (gespiegelt) ---
    color("Khaki", 0.9)
    translate([wing_offset_x, 0, wing_offset_z])
        mirror([0, 1, 0])
            rotate([wing_x_rotate, wing_y_rotate, wing_z_rotate]) 
                    half_wing();

    // --- Rumpf ---
    // color("Gold", 0.9)
    //     fuselage();

    // --- Leitwerk ---
    // color("Khaki", 0.9)
    //     translate([fuselage_length - tail_chord, 0, tail_z])
    //         tail();

    // --- Motor ---
    // color("DarkRed", 0.9)
    //     engine_cowl();

    // --- Fahrwerk ---
    // color("DarkGray")
    //     landing_gear();
}

// ============================================================
// RENDER
// ============================================================

baron();
