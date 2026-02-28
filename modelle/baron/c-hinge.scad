// c-hinge.scad

od        = 8.0;   // [mm] Außendurchmesser C-Clip
wall      = 1.2;   // [mm] Wandstärke C-Clip
h         = 40;    // [mm] Länge
clearance = 0.2;   // [mm] Spiel zwischen Stab und C-Clip (allseitig)

rod_od = od - 2*wall - 2*clearance;  // = 5.2 mm
fin_t  = 1.6;   // [mm] Dicke der Flosse (4 × 0.4mm Düse)

open_a   = 100;  // [°] Öffnungswinkel des Catch-Rings
open_dir = 225;  // [°] Richtung der Öffnungsmitte (0°=+X, 90°=+Y, 225°=unten-links)

$fn = 64;

// ── Hilfmodul: Kreissektor (Pie-Slice) ──────────────────────────
// entspricht einer 2D-Skizze mit Bogen, extrudiert auf Höhe h
module wedge(r, angle, height) {
    n = max(2, ceil(angle));
    linear_extrude(height)
        polygon(concat(
            [[0, 0]],
            [for (i = [0:n]) [r * cos(i * angle / n),
                              r * sin(i * angle / n)]]
        ));
}

// ── C-Clip (Ruder) ───────────────────────────────────────────────
color("gold")
difference() {
    union() {
        cylinder(d = od, h = h);
        translate([0, -od/2, 0])
            cube([20, od, h]);  
            }
    translate([0, 0, -0.1])
        cylinder(d = od - 2 * wall, h = h + 0.2);
    rotate([0, 0, -45])
        translate([-od, -od, -0.1])
            cube([8, 8, h + 0.2]);
}

// ── Stab (Flosse) ────────────────────────────────────────────────
color("steelblue")
union() {
    // center
    cylinder(d = rod_od, h = h);
    translate([-(od+clearance)/2, -fin_t/2, 0])
        cube([od/2, fin_t, h]);
    
    // catch
    difference() {
        cylinder(d = od+clearance+wall, h = h);
        // Innenbohrung
        translate([0, 0, -0.1])
            cylinder(d = od+clearance, h = h+0.2);
        // Öffnungsschnitt (Pie-Slice Wedge)
        translate([0, 0, -0.1])
            rotate([0, 0, open_dir - open_a/2])
                wedge(od + clearance + wall + 1, open_a, h + 0.2);
    }
}
