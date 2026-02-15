// wing.scad – Hauptflügel-Konfiguration
// Nutzt elliptic_wing.scad als Geometrie-Kern.

show_preview = false;

include <elliptic_wing.scad>

module main_wing(y_start = 0, y_end = half_span) {
    wing(y_start, y_end);
}

module main_aileron(y_start = aileron_y1 - aileron_gap, y_end = aileron_y2 + aileron_gap) {
    aileron(y_start, y_end);
}

function wing_seg_boundary(i) = seg_boundary(i);

module main_wing_segment(index) {
    wing_segment(wing_seg_boundary(index), wing_seg_boundary(index + 1));
}

module main_aileron_segment(index) {
    aileron_part(wing_seg_boundary(index), wing_seg_boundary(index + 1));
}

main_wing();