// airfoil.scad – NACA 4-digit airfoil profile generator
// Generates 2D airfoil profiles for use in wing construction
// Units: mm

// Generate a NACA 4-digit airfoil as a list of [x,y] points
// Parameters:
//   naca  - 4-digit NACA code as vector [m, p, tt]
//           m  = max camber (% chord / 100)
//           p  = position of max camber (tenths of chord / 10)
//           tt = max thickness (% chord / 100)
//   chord - chord length in mm
//   n     - number of points per side (more = smoother)
//
// Example: NACA 2412 → naca=[0.02, 0.4, 0.12]

function naca_half_thickness(tt, x) =
    5 * tt * (
        0.2969 * sqrt(x)
        - 0.1260 * x
        - 0.3516 * pow(x, 2)
        + 0.2843 * pow(x, 3)
        - 0.1015 * pow(x, 4)
    );

function naca_camber(m, p, x) =
    (x < p)
        ? (m / pow(p, 2)) * (2 * p * x - pow(x, 2))
        : (m / pow(1 - p, 2)) * ((1 - 2 * p) + 2 * p * x - pow(x, 2));

function naca_camber_gradient(m, p, x) =
    (x < p)
        ? (2 * m / pow(p, 2)) * (p - x)
        : (2 * m / pow(1 - p, 2)) * (p - x);

// Generate airfoil points (upper + lower surface, closed polygon)
function naca_points(naca, chord, n = 40) =
    let(
        m  = naca[0],
        p  = max(naca[1], 0.001),  // avoid division by zero
        tt = naca[2],
        // Cosine spacing for better leading edge resolution
        xs = [for (i = [0:n]) 0.5 * (1 - cos(i * 180 / n))],
        upper = [for (i = [0:n])
            let(
                x  = xs[i],
                yt = naca_half_thickness(tt, x),
                yc = naca_camber(m, p, x),
                theta = atan2(naca_camber_gradient(m, p, x), 1)
            )
            [chord * (x - yt * sin(theta)),
             chord * (yc + yt * cos(theta))]
        ],
        lower = [for (i = [n:-1:0])
            let(
                x  = xs[i],
                yt = naca_half_thickness(tt, x),
                yc = naca_camber(m, p, x),
                theta = atan2(naca_camber_gradient(m, p, x), 1)
            )
            [chord * (x + yt * sin(theta)),
             chord * (yc - yt * cos(theta))]
        ]
    )
    concat(upper, [for (i = [1:len(lower)-2]) lower[i]]);

// 2D airfoil shape as polygon
module airfoil_2d(naca, chord, n = 40) {
    polygon(points = naca_points(naca, chord, n));
}

// Common NACA profiles as convenience constants
// Format: [max_camber, camber_position, thickness]
NACA_2412 = [0.02, 0.4, 0.12];  // Classic general aviation
NACA_4412 = [0.04, 0.4, 0.12];  // Higher lift, good for slow flight
NACA_4415 = [0.04, 0.4, 0.15];  // Thicker, more lift at low speed
NACA_2415 = [0.02, 0.4, 0.15];  // Moderate camber, thick
NACA_0012 = [0.00, 0.0, 0.12];  // Symmetric (for tail surfaces)
NACA_0009 = [0.00, 0.0, 0.09];  // Symmetric, thin (tail)
NACA_23012 = [0.02, 0.3, 0.12]; // Approximation for 5-digit
