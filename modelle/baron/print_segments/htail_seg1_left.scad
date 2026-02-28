// htail_seg1_left.scad – Höhenleitwerk Segment 1 (mit Höhenruder-Zone), links
// Spannweite 0–(200-gap) mm
//
// Export getrennt für saubere Slicer-Perimeter:
//   openscad -o htail_seg1_left_shell.stl -D "layer=\"shell\"" htail_seg1_left.scad
//   openscad -o htail_seg1_left_ribs.stl  -D "layer=\"ribs\""  htail_seg1_left.scad
// Dann beide STLs als Teile eines Objekts im Slicer laden.

layer = "all";  // überschreibbar via -D 'layer="shell"' / 'layer="ribs"'

use <../tailplane.scad>

tail_segment(0, layer);
