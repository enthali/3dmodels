// htail_seg2_left.scad – Höhenleitwerk Segment 2 (Randbogen), links
// Spannweite (200-gap)–240 mm
//
// Export getrennt:
//   openscad -o htail_seg2_left_shell.stl -D "layer=\"shell\"" htail_seg2_left.scad
//   openscad -o htail_seg2_left_ribs.stl  -D "layer=\"ribs\""  htail_seg2_left.scad

layer = "all";

use <../tailplane.scad>

tail_segment(1, layer);
