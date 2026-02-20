// wing.scad – Hauptflügel-Konfiguration
// Nutzt elliptic_wing.scad als Geometrie-Kern.

// --- Wing Parameter ---
wing_naca         = [0.04, 0.4, 0.15];  // NACA 4415
chord_root        = 180;                 // [mm]
half_span         = 600;                 // [mm]
step              = $preview ? 10 : 0.2;
tip_min           = 5;

wall              = 0.4;
rib_wall          = 0.8;
rib_angle         = 45;
rib_spacing       = 40;
rib_inset_root    = 5;
rib_inset_min     = 2;
rib_inset_r       = 1;
steg_w_root       = 7;
min_hole_chord    = 30;

v_angle           = 3;
washout           = 3;
washout_start     = 0;
sweep_ref         = 0.30;

aileron_hinge_pct = 0.79;
aileron_hinge_sweep = -8.2;
aileron_gap       = 0.8;
aileron_bevel     = 30;

groove_inset      = 40;

$fn               = $preview ? 24 : 64;

_seg_unit         = round(half_span / 4.5 / step) * step;
aileron_y1        = 2 * _seg_unit;
aileron_y2        = 4 * _seg_unit;
segment_bounds    = [
    0,
    1 * _seg_unit,
    2 * _seg_unit - aileron_gap,
    3 * _seg_unit,
    4 * _seg_unit + aileron_gap/2,
    half_span
];

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