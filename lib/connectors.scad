// connectors.scad – Steckverbindungen für mehrteilige Drucke
// Units: mm

// Toleranz für FDM-Passungen
FDM_TOLERANCE = 0.2;  // mm, wird zum Loch addiert

// Rechteckiger Steckverbinder (Zapfen)
// Wird in das Teil integriert, das eingesteckt wird
module connector_pin(width, height, depth, tolerance = 0) {
    translate([0, 0, 0])
        cube([width - tolerance, height - tolerance, depth], center = true);
}

// Rechteckige Aufnahme (Buchse)
// Wird in das Teil integriert, das den Zapfen aufnimmt
module connector_socket(width, height, depth, tolerance = FDM_TOLERANCE) {
    translate([0, 0, 0])
        cube([width + tolerance, height + tolerance, depth + 0.5], center = true);
}

// Runder Steckverbinder (für Holme / Carbonrohre)
// d = Durchmesser, l = Länge
module spar_hole(d, l, tolerance = FDM_TOLERANCE) {
    cylinder(d = d + tolerance, h = l, center = true, $fn = 32);
}

module spar_pin(d, l, tolerance = 0) {
    cylinder(d = d - tolerance, h = l, center = true, $fn = 32);
}

// Flügelverbinder mit Holmaufnahme
// Für Carbon-Rundstab als Flügelholm
module wing_connector(spar_d, width, height, depth, tolerance = FDM_TOLERANCE) {
    difference() {
        connector_pin(width, height, depth);
        spar_hole(spar_d, depth + 1, tolerance);
    }
}
