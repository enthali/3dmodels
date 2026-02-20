// tailplane.scad – Elliptisches Höhenleitwerk (parametrisch)
// Nutzt den Geometrie-Kern aus elliptic_wing.scad mit angepassten Parametern.

// --- Tailplane Parameter ---
wing_naca         = [0, 0, 0.09];  // NACA 0009
chord_root        = 120;            // [mm]
half_span         = 220;            // [mm] => 440 mm Gesamtspannweite
step              = $preview ? 5 : 0.2;
tip_min           = 5;

wall              = 0.4;
rib_wall          = 0.8;
rib_angle         = 45;
rib_spacing       = 35;
rib_inset_root    = 5;
rib_inset_min     = 2;
rib_inset_r       = 1;
steg_w_root       = 7;
min_hole_chord    = 30;

v_angle           = 0;
washout           = 0;
washout_start     = 0;
sweep_ref         = 0.50;

// Höhenruder über Segment 1: 0–200 mm
aileron_hinge_pct = 0.67;  // 33% Rudertiefe
aileron_hinge_sweep = 0;   // 0° = Scharnierachse quer zur Flugrichtung
aileron_gap       = 0.8;
aileron_bevel     = 30;
aileron_y1        = 0;
aileron_y2        = 200;

// 2 Segmente: 0–200 (mit Ruder), 200–220 (Randbogen)
segment_bounds    = [0, aileron_y2 - aileron_gap, half_span];
groove_inset      = 40;
$fn               = $preview ? 24 : 64;

show_preview      = false;

include <elliptic_wing.scad>

// --- Komfort-Wrapper ---
module tailplane(y_start = 0, y_end = half_span) {
    wing(y_start, y_end);
}

module elevator(y_start = 0, y_end = aileron_y2 + aileron_gap) {
    aileron(y_start, y_end);
}

module tail_segment(index) {
    wing_segment(tail_seg_boundary(index), tail_seg_boundary(index + 1));
}

module elevator_segment(y_start = 0, y_end = aileron_y2 + aileron_gap) {
    aileron_part(y_start, y_end);
}

function tail_seg_boundary(i) = segment_bounds[i];
tailplane();