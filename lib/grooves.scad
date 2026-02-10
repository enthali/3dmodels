// grooves.scad – Filament-Verstärkungsnuten für Tragflächen
// Halbschalen auf der Profiloberfläche: Filament einklemmen + Sekundenkleber
//
// Benötigt: airfoil.scad (für airfoil_2d)

use <airfoil.scad>

// === Parameter (können vom Hauptprojekt überschrieben werden) ===
groove_d        = 1.75;   // [mm] Nutbreite = Filament-∅ (H-Passung, Filament meist <1.75)
groove_sink     = 1.80;   // [mm] Gesamttiefe der U-Nut (Filament versenkt, kaum Überstand)
groove_inset    = 40;     // [mm] Abstand von Nase bzw. Endleiste
groove_min_chord = 2 * groove_inset;  // Nuten nur bei chord ≥ 2×inset

// === NACA Oberflächen-Funktionen ===
// Berechnet Y-Koordinate der Profiloberfläche an Position x_abs [mm]

function naca_yt(x, t) =
    5 * t * (0.2969*sqrt(x) - 0.1260*x - 0.3516*pow(x,2)
            + 0.2843*pow(x,3) - 0.1015*pow(x,4));

function naca_yc(x, m, p) =
    let(p2 = max(p, 0.001))  // division by zero schutz
    x <= p2 ? m/pow(p2,2) * (2*p2*x - pow(x,2))
            : m/pow(1-p2,2) * (1 - 2*p2 + 2*p2*x - pow(x,2));

function airfoil_y_upper(x_abs, naca, chord) =
    let(xn = max(0.001, min(x_abs / chord, 0.999)))
    chord * (naca_yc(xn, naca[0], naca[1]) + naca_yt(xn, naca[2]));

function airfoil_y_lower(x_abs, naca, chord) =
    let(xn = max(0.001, min(x_abs / chord, 0.999)))
    chord * (naca_yc(xn, naca[0], naca[1]) - naca_yt(xn, naca[2]));

// === Haupt-Module ===

// U-förmige Nut (2D): gerade Wände + Halbkreis am Boden
// Öffnung nach oben (Y+), Gesamttiefe = groove_sink
module groove_u_2d() {
    r = groove_d / 2;
    wall_h = max(0, groove_sink - r);  // Wandhöhe über dem Kreiszentrum
    // Halbkreis am Boden (Zentrum bei -wall_h)
    translate([0, -wall_h])
        circle(d = groove_d);
    // Gerade Wände darüber (bis zur Oberfläche)
    if (wall_h > 0)
        translate([-groove_d/2, -wall_h])
            square([groove_d, wall_h + r]);
}

// 2D-Profil mit 4 Filament-U-Nuten (vorne/hinten × oben/unten)
// Nut-Öffnung zeigt nach außen, Filament sitzt fast bündig
module airfoil_grooved_2d(naca, chord, n = 40) {
    if (chord >= groove_min_chord) {
        x_front = groove_inset;
        x_back  = chord - groove_inset;
        difference() {
            airfoil_2d(naca, chord, n);
            // Vorne oben (U öffnet nach oben)
            translate([x_front, airfoil_y_upper(x_front, naca, chord)])
                groove_u_2d();
            // Vorne unten (U öffnet nach unten → mirror)
            translate([x_front, airfoil_y_lower(x_front, naca, chord)])
                mirror([0, 1]) groove_u_2d();
            // Hinten oben
            translate([x_back, airfoil_y_upper(x_back, naca, chord)])
                groove_u_2d();
            // Hinten unten
            translate([x_back, airfoil_y_lower(x_back, naca, chord)])
                mirror([0, 1]) groove_u_2d();
        }
    } else {
        airfoil_2d(naca, chord, n);
    }
}
