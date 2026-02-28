// elevator_left_seg1.scad – Höhenruder Segment 1, links
// Höhenruderbereich: 0–(200+gap) mm
//
// Export getrennt:
//   openscad -o elevator_left_seg1_shell.stl -D "layer=\"shell\"" elevator_left_seg1.scad
//   openscad -o elevator_left_seg1_ribs.stl  -D "layer=\"ribs\""  elevator_left_seg1.scad

layer = "all";

use <../tailplane.scad>

elevator_segment(layer=layer);
