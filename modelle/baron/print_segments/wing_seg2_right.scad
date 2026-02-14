// seg2_right.scad – Mittleres Segment, rechter Halbflügel (gespiegelt)
// Spannweite 200–400mm, mit Holm-Kanal

use <../elliptic_wing.scad>

mirror([0, 0, 1])
    half_wing_segment(200, 400);
