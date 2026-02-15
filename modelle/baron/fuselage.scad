// fuselage.scad – Baron Rumpf (parametrisch)
// Ansatz: station-basierter Loft per hull() zwischen Querschnitten
// Form: runde Nase -> ausgebeultes, abgerundetes Rechteck -> verjüngtes Heck

// ============================================================
// PARAMETER
// ============================================================

$fn = $preview ? 32 : 128;

// Zielabmessungen Gesamt-Rumpf
fuselage_length = 800;   // [mm] Gesamtlänge Nase -> Heck
fuselage_width  = 62;    // [mm] maximale Rumpfbreite
fuselage_height = 50;    // [mm] maximale Rumpfhöhe

wall            = 0.45;   // [mm] dünne Hülle, ähnlich Flügel
section_thick   = 0.6;    // [mm] dünne Scheibe pro Station für hull

// Innenverstärkung
add_ribs        = true;
rib_spacing     = 35;     // [mm]
rib_thickness   = 0.8;    // [mm] 2 Linien bei 0.4er Düse

add_longerons   = true;
longeron_d      = 1.2;    // [mm] Stringer-Durchmesser

// Basisprofil [x, width, height, corner_r]
// X = Längsachse (Nase -> Heck), Querschnitt liegt in YZ
base_stations = [
    [   0, 24, 24, 12],   // runde Nase
    [  54, 36, 34, 10],   // schneller Übergang
    [ 169, 62, 50, 10],   // "ausgebeult" (max. Volumen)
    [ 246, 58, 46,  9],   // bei Nasenleiste: abgerundetes Rechteck erreicht
    [ 431, 46, 38,  7],   // hinter Flügelbereich
    [ 662, 26, 24,  5],   // Richtung Leitwerk
    [ 800, 12, 12,  4]    // Endstück
];

// ============================================================
// HILFSFUNKTIONEN
// ============================================================

function _min2(a, b) = a < b ? a : b;
function _base(i, k) = base_stations[i][k];

function _base_len_x() = _base(len(base_stations) - 1, 0);

function _base_max_width(i = 0, acc = 0) =
    i >= len(base_stations) ? acc : _base_max_width(i + 1, _base(i, 1) > acc ? _base(i, 1) : acc);

function _base_max_height(i = 0, acc = 0) =
    i >= len(base_stations) ? acc : _base_max_height(i + 1, _base(i, 2) > acc ? _base(i, 2) : acc);

base_len_x = _base_len_x();
base_max_w = _base_max_width();
base_max_h = _base_max_height();

scale_x = fuselage_length / base_len_x;
scale_w = fuselage_width  / base_max_w;
scale_h = fuselage_height / base_max_h;

function _sx(i) = _base(i, 0) * scale_x;
function _sw(i) = _base(i, 1) * scale_w;
function _sh(i) = _base(i, 2) * scale_h;
function _sr(i) = _base(i, 3) * _min2(scale_w, scale_h);

function _len_x() = _sx(len(base_stations) - 1);

max_w = fuselage_width;
max_h = fuselage_height;

// ============================================================
// GEOMETRIE-BASIS
// ============================================================

module rr_2d(w, h, r) {
    rr = _min2(r, _min2(w, h) / 2);
    offset(r = rr)
        square([w - 2 * rr, h - 2 * rr], center = true);
}

module section_outer(x, w, h, r) {
    translate([x, 0, 0])
        rotate([0, 90, 0])
            linear_extrude(height = section_thick, center = true)
                rr_2d(w, h, r);
}

module section_inner(x, w, h, r) {
    iw = w - 2 * wall;
    ih = h - 2 * wall;
    ir = _min2(r - wall, _min2(iw, ih) / 2);

    if (iw > 0 && ih > 0 && ir >= 0)
        translate([x, 0, 0])
            rotate([0, 90, 0])
                linear_extrude(height = section_thick + 0.01, center = true)
                    rr_2d(iw, ih, ir);
}

module loft_outer() {
    for (i = [0 : len(base_stations) - 2]) {
        hull() {
            section_outer(_sx(i), _sw(i), _sh(i), _sr(i));
            section_outer(_sx(i + 1), _sw(i + 1), _sh(i + 1), _sr(i + 1));
        }
    }
}

module loft_inner() {
    for (i = [0 : len(base_stations) - 2]) {
        hull() {
            section_inner(_sx(i), _sw(i), _sh(i), _sr(i));
            section_inner(_sx(i + 1), _sw(i + 1), _sh(i + 1), _sr(i + 1));
        }
    }
}

module shell() {
    difference() {
        loft_outer();
        loft_inner();
    }
}

// ============================================================
// INNENVERSTÄRKUNG
// ============================================================

module ribs_inside() {
    for (x = [rib_spacing : rib_spacing : _len_x() - rib_spacing]) {
        intersection() {
            loft_inner();
            translate([x - rib_thickness / 2, -max_w, -max_h])
                cube([rib_thickness, 2 * max_w, 2 * max_h]);
        }
    }
}

module longeron(y, z) {
    intersection() {
        loft_inner();
        translate([0, y, z])
            rotate([0, 90, 0])
                cylinder(h = _len_x(), d = longeron_d);
    }
}

module longerons_inside() {
    longeron(0,  max_h * 0.22);   // oben mittig
    longeron(0, -max_h * 0.22);   // unten mittig
    longeron( max_w * 0.22, 0);   // rechts mittig
    longeron(-max_w * 0.22, 0);   // links mittig
}

// ============================================================
// ÖFFENTLICHES MODUL
// ============================================================

module fuselage_baron() {
    union() {
        shell();

        if (add_ribs)
            ribs_inside();

        if (add_longerons)
            longerons_inside();
    }
}

fuselage_baron();
