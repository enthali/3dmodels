// wing_seg3_left.scad – Querruder-Zone, linker Halbflügel (Flügel ohne Ruder)
// Spannweite 330–550 mm (Querruder-Ausschnitt ist in half_wing() eingebaut)

use <../elliptic_wing.scad>

half_wing_segment(seg_boundary(2), seg_boundary(3));
