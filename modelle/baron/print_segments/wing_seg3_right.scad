// seg3_right.scad – Äußeres Segment (Tip), rechter Halbflügel (gespiegelt)
// Spannweite 400–600mm, ohne Holm

use <../elliptic_wing.scad>
rotate([180,0,0])
    mirror([0, 0, 1])
        half_wing_segment(400, 600);
