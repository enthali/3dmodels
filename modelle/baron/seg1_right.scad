// seg1_right.scad – Inneres Segment, rechter Halbflügel (gespiegelt)
// Spannweite 0–200mm (Wurzel), mit Holm-Kanal

use <elliptic_wing.scad>

mirror([0, 0, 1])
    half_wing_segment(0, 200);
