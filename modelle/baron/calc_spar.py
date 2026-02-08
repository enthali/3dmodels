import math

chord_root = 180
half_span = 600
tc = 0.15
m, p = 0.04, 0.4
xc = 0.30

yt = tc/0.2 * (0.2969*math.sqrt(xc) - 0.1260*xc - 0.3516*xc**2 + 0.2843*xc**3 - 0.1015*xc**4)
yc = m / p**2 * (2*p*xc - xc**2)

y_upper = (yc + yt) * chord_root
y_lower = (yc - yt) * chord_root
spar_y = y_upper - 4  # Holm 4mm unter Oberkante

print(f"Wurzel (chord={chord_root}mm):")
print(f"  Profil bei 30%: Oben={y_upper:.1f}mm  Unten={y_lower:.1f}mm  Hoehe={y_upper-y_lower:.1f}mm")
print(f"  Holm-Mitte: Y={spar_y:.1f}mm ueber Sehne")
print()
print(f"{'y':>5} {'chord':>6} {'oben':>6} {'unten':>6} {'V-off':>6} {'Holm_rel':>8} {'OK':>5}")
print("-" * 50)

for y in [0, 50, 100, 200, 300, 400, 450, 500, 550]:
    c = max(15, chord_root * math.sqrt(1 - (y/half_span)**2))
    y_up = (yc + yt) * c
    y_lo = (yc - yt) * c
    v_off = math.tan(math.radians(3)) * y
    holm_rel = spar_y - v_off
    if holm_rel + 3 > y_up:
        ok = "NEIN"
    elif holm_rel - 3 < y_lo:
        ok = "NEIN"
    elif holm_rel + 3 > y_up - 1:
        ok = "KNAPP"
    else:
        ok = "OK"
    print(f"{y:5d} {c:6.1f} {y_up:6.1f} {y_lo:6.1f} {v_off:6.1f} {holm_rel:8.1f} {ok:>5}")
