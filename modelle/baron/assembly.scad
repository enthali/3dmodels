// assembly.scad – Baron RC-Flugzeug Gesamtansicht
// Elliptischer Flügel aus Segmenten zusammengesetzt
//
// Koordinatensystem:
//   X = Längsachse (Nase → Heck)
//   Y = Querachse (links → rechts, Spannweite)
//   Z = Hochachse (unten → oben)

use <elliptic_wing.scad>


// ============================================================
// PARAMETER
// ============================================================

// --- Rumpf (Platzhalter) ---
fuselage_width  = 80;    // [mm] Rumpfbreite
fuselage_length = 800;   // [mm] Rumpflänge

// --- Flügel-Positionierung ---
wing_offset_x   = 150;   // [mm] Flügelvorderkante ab Rumpfnase
wing_offset_z   = 120;    // [mm] Flügelhöhe (Schulterdecker)

// --- Segment-Grenzen [mm] (aus elliptic_wing.scad) ---
// seg_boundary(0..4): 0, 200, 330, 550, 600

// --- Explosionsansicht ---
explode = 0;             // [mm] Abstand zwischen Segmenten (0 = zusammen)

// ============================================================
// BAUGRUPPEN
// ============================================================

// Halbflügel aus Segmenten + Querruder zusammensetzen
// elliptic_wing.scad: Profil in XY, Spannweite in Z
// rotate([90,0,0]): Z → -Y, Y → Z  (Spannweite nach links, Oberseite nach oben)
module place_half_wing() {
    // Segment 1: Wurzel (0–200 mm)
    translate([0, -(seg_boundary(0) + 0 * explode), 0])
        rotate([90, 0, 0])
            half_wing_segment(seg_boundary(0), seg_boundary(1));

    // Segment 2: Innen bis Querruder (200–330 mm)
    translate([0, -(seg_boundary(1) + 1 * explode), 0])
        rotate([90, 0, 0])
            half_wing_segment(seg_boundary(1), seg_boundary(2));

    // Segment 3: Querruder-Zone – Flügel mit Ausschnitt (330–550 mm)
    translate([0, -(seg_boundary(2) + 2 * explode), 0])
        rotate([90, 0, 0])
            half_wing_segment(seg_boundary(2), seg_boundary(3));

    // Querruder (separates Teil)
    color("Orange", 0.9)
    translate([0, -(seg_boundary(2) + 2 * explode), 0])
        rotate([90, 0, 0])
            aileron_part();

    // Segment 4: Flügelspitze (550–600 mm)
    translate([0, -(seg_boundary(3) + 3 * explode), 0])
        rotate([90, 0, 0])
            half_wing_segment(seg_boundary(3), seg_boundary(4));
}

// Rumpf-Platzhalter (einfacher Quader zur Orientierung)
module fuselage_placeholder() {
    translate([0, -fuselage_width/2, 0])
        cube([fuselage_length, fuselage_width, wing_offset_z + 30]);
}

// ============================================================
// ZUSAMMENBAU
// ============================================================

module baron() {
    // --- Flügel links ---
    color("Khaki", 0.9)
    translate([wing_offset_x, 0, wing_offset_z])
        place_half_wing();

    // --- Flügel rechts (gespiegelt) ---
    // color("Khaki", 0.9)
    // translate([wing_offset_x, 0, wing_offset_z])
    //    mirror([0, 1, 0])
    //        place_half_wing();

    // --- Rumpf (Platzhalter) ---
    //color("Gold", 0.3)
    //    fuselage_placeholder();

    // --- Leitwerk ---
    // color("Khaki", 0.9)
    //     tail();

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
