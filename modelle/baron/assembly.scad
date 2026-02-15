// assembly.scad – Baron RC-Flugzeug Gesamtansicht
// Elliptischer Flügel + Höhenleitwerk aus Segmenten zusammengesetzt
//
// Koordinatensystem:
//   X = Längsachse (Nase → Heck)
//   Y = Querachse (links → rechts, Spannweite)
//   Z = Hochachse (unten → oben)

use <wing.scad>
use <tailplane.scad>
use <fuselage.scad>


// ============================================================
// PARAMETER
// ============================================================

// --- Flügel-Positionierung ---
wing_offset_x   = 150;   // [mm] Flügelvorderkante ab Rumpfnase
wing_offset_z   = 120;    // [mm] Flügelhöhe (Schulterdecker)
wing_incidence  = 3;      // [°] Einstellwinkel (Nase hoch)

// --- Höhenleitwerk-Positionierung ---
tail_offset_x   = 650;    // [mm] HLW-Vorderkante ab Rumpfnase
tail_offset_z   = 20;     // [mm] HLW-Höhe am Heck
tail_incidence  = 0;      // [°]

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
    translate([0, -(wing_seg_boundary(0) + 1 * explode), 0])
        rotate([90, 0, 0])
            main_wing_segment(0);

    // Segment 2: Innen bis Querruder
    translate([0, -(wing_seg_boundary(1) + 2 * explode), 0])
        rotate([90, 0, 0])
            main_wing_segment(1);

    // Segment 3: Querruder-Zone – Flügel mit Ausschnitt
    translate([0, -(wing_seg_boundary(2) + 3 * explode), 0])
        rotate([90, 0, 0])
            main_wing_segment(2);

    // Querruder Segment 1 (innen)
    translate([.5 * explode, -(wing_seg_boundary(2) + 3.5 * explode), 0])
        rotate([90, 0, 0])
            main_aileron_segment(2);

    // Querruder Segment 2 (außen)
    translate([.5 * explode, -(wing_seg_boundary(3) + 4.5 * explode), 0])
        rotate([90, 0, 0])
            main_aileron_segment(3);

    // Segment 4: Querruder-Ende bis Randbogen
    translate([0, -(wing_seg_boundary(3) + 4 * explode), 0])
        rotate([90, 0, 0])
            main_wing_segment(3);

    // Segment 5: Randbogen
    translate([0, -(wing_seg_boundary(4) + 5 * explode), 0])
        rotate([90, 0, 0])
            main_wing_segment(4);
}

// Halb-Höhenleitwerk aus Segmenten + Höhenruder zusammensetzen
module place_half_tailplane() {
    // Segment 1: Innenbereich mit Höhenruder-Zone
    translate([0, -(tail_seg_boundary(0) + 1 * explode), 0])
        rotate([90, 0, 0])
            tail_segment(0);

    // Höhenruder (bis Segmentgrenze)
    translate([.5 * explode, -(tail_seg_boundary(0) + 1.5 * explode), 0])
        rotate([90, 0, 0])
            elevator_segment();

    // Segment 2: Randbogen
    translate([0, -(tail_seg_boundary(1) + 2 * explode), 0])
        rotate([90, 0, 0])
            tail_segment(1);
}

// ============================================================
// ZUSAMMENBAU
// ============================================================

module baron() {
    // --- Flügel links ---
    color("Red", 0.8)
    translate([wing_offset_x, 0, wing_offset_z])
        rotate([0, wing_incidence, 0])
            place_half_wing();

    // --- Flügel rechts (gespiegelt) ---
    color("Green", 0.8)
    translate([wing_offset_x, 0, wing_offset_z])
        rotate([0, wing_incidence, 0])
            mirror([0, 1, 0])
                place_half_wing();

    // --- Rumpf (Platzhalter) ---
    color("Gold", 0.3)
        fuselage_baron();

    // --- Höhenleitwerk links ---
    color("Khaki", 0.85)
    translate([tail_offset_x, 0, tail_offset_z])
        rotate([0, tail_incidence, 0])
            place_half_tailplane();

    // --- Höhenleitwerk rechts (gespiegelt) ---
    color("Peru", 0.85)
    translate([tail_offset_x, 0, tail_offset_z])
        rotate([0, tail_incidence, 0])
            mirror([0, 1, 0])
                place_half_tailplane();

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
