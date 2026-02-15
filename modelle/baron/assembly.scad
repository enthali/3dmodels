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
explode = 10;             // [mm] Abstand zwischen Segmenten (0 = zusammen)

// ============================================================
// BAUGRUPPEN
// ============================================================

// Halbflügel aus Segmenten + Querruder zusammensetzen
// elliptic_wing.scad: Profil in XY, Spannweite in Z
// rotate([90,0,0]): Z → -Y, Y → Z  (Spannweite nach links, Oberseite nach oben)
module place_half_wing() {
    // Segment 1: Wurzel
    translate([0, -(seg_boundary(0) + 1 * explode), 0])
        rotate([90, 0, 0])
            wing_segment(seg_boundary(0), seg_boundary(1));

    // Segment 2: Innen bis Querruder
    translate([0, -(seg_boundary(1) + 2 * explode), 0])
        rotate([90, 0, 0])
            wing_segment(seg_boundary(1), seg_boundary(2));

    // Segment 3: Querruder-Zone – Flügel mit Ausschnitt
    translate([0, -(seg_boundary(2) + 3 * explode), 0])
        rotate([90, 0, 0])
            wing_segment(seg_boundary(2), seg_boundary(3));

    // Querruder Segment 1 (innen)
    color("Orange", 0.9)
    translate([1 * explode, -(seg_boundary(2) + 3.5 * explode), 0])
        rotate([90, 0, 0])
            aileron_part(seg_boundary(2), seg_boundary(3));

    // Querruder Segment 2 (außen)
    color("Orange", 0.9)
    translate([1 * explode, -(seg_boundary(3) + 4.5 * explode), 0])
        rotate([90, 0, 0])
            aileron_part(seg_boundary(3), seg_boundary(4));

    // Segment 4: Querruder-Ende bis Randbogen
    translate([0, -(seg_boundary(3) + 4 * explode), 0])
        rotate([90, 0, 0])
            wing_segment(seg_boundary(3), seg_boundary(4));

    // Segment 5: Randbogen
    translate([0, -(seg_boundary(4) + 5 * explode), 0])
        rotate([90, 0, 0])
            wing_segment(seg_boundary(4), seg_boundary(5));
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
    color("Khaki", 0.9)
    translate([wing_offset_x, 0, wing_offset_z])
        mirror([0, 1, 0])
            place_half_wing();

    // --- Rumpf (Platzhalter) ---
    color("Gold", 0.3)
        fuselage_placeholder();

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
