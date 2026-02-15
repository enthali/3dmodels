# Baron – 1920er Schulterdecker RC-Modell

## Beschreibung

RC-Modellflugzeug inspiriert von Schulterdeckern der 1920er/30er Jahre.
Der Rumpf orientiert sich an der **Spirit of St. Louis** – kastig, funktional, mit Charakter.
Parametrisches Design in OpenSCAD, komplett FDM-druckbar, segmentiert für den Adventurer 5M.

### Design-Philosophie

- **Per-Slice Architektur**: Jede Schicht wird komplett in 2D berechnet, dann extrudiert (0.2mm = 1 Layer)
- **Elliptische Planform**: Optimale Auftriebsverteilung, minimaler induzierter Widerstand
- **Selbsttragende Hohlschale**: Kreuzrippen + Filament-Nuten statt separatem Holm
- **Crash & Replace**: Segmentiert → Einzelteile nachdruckbar

## Technische Daten

| Parameter | Wert |
|---|---|
| **Spannweite** | 1200 mm |
| **Rumpflänge** | 800 mm |
| **Flügelprofil** | NACA 4415 |
| **Wurzeltiefe** | 180 mm |
| **Halbspannweite** | 600 mm (5 Segmente pro Seite) |
| **Einstellwinkel** | 3° |
| **Schränkung (Washout)** | 3° linear |
| **Pfeilungs-Referenz** | 30% Chord |
| **Wandstärke Hülle** | 0.4 mm (1× Düse) |
| **Rippenstärke** | 0.8 mm (2× Düse) |
| **Rippenwinkel** | ±45° Kreuzrippen, 40 mm Abstand |
| **Querruder** | 2/3 Spannweite, 21% Chord, 30° Bevel |
| **Querruder-Spalt** | 0.8 mm |
| **Höhenleitwerk (neu)** | 480 mm Spannweite (240 mm Halbspannweite), voll-elliptisch |
| **Höhenruder (neu)** | 0–200 mm je Halbseite, 30% Chord, 30° Bevel |
| **Antrieb** | 3S LiPo, ~1100–1300 KV Outrunner |

### Flügelarchitektur

```
  Segment 1    Segment 2    Segment 3    Segment 4    Segment 5
  (Wurzel)     (Innen)      (QR-Zone)    (QR-Zone)    (Randbogen)
 |------------|------------|------------|------------|------|
 0          133.4        266.0        400.2        534.4    600 mm
                          ◄── Querruder (2 Teile) ──►
```

- **Segment-Raster**: 1:1:1:1:0.5 Verhältnis (~133 mm Einheit)
- **Querruder**: Segmente 3+4, mit Bevel-Scharnier und separaten Abschlusswänden
- **Filament-Nuten**: Bei Chord ≥ 80 mm, vorne + hinten (Inset 40 mm)

## Zielmaschine

**FlashForge Adventurer 5M** (220 × 220 × 220 mm FDM)

## Segmentierung

| Teil | Datei(en) | Maße ca. |
|---|---|---|
| Flügel Seg. 1 (Wurzel) | `wing_seg1_left.scad` | 180 × 27 × 133 mm |
| Flügel Seg. 2 (Innen) | `wing_seg2_left.scad` | 170 × 26 × 133 mm |
| Flügel Seg. 3 (QR-Zone) | `wing_seg3_left.scad` | 150 × 23 × 134 mm |
| Flügel Seg. 4 (QR-Zone) | `wing_seg4_left.scad` | 120 × 18 × 134 mm |
| Flügel Seg. 5 (Randbogen) | `wing_seg5_left.scad` | 80 × 12 × 66 mm |
| Querruder Seg. 1 (innen) | `aileron_left_seg1.scad` | ~30 × 23 × 134 mm |
| Querruder Seg. 2 (außen) | `aileron_left_seg2.scad` | ~25 × 18 × 134 mm |
| Höhenleitwerk Seg. 1 | `htail_seg1_left.scad` | ~100 × variabel × 199 mm |
| Höhenleitwerk Seg. 2 (Randbogen) | `htail_seg2_left.scad` | ~40 × variabel × 41 mm |
| Höhenruder Seg. 1 | `elevator_left_seg1.scad` | ~30 × variabel × 201 mm |
| Rumpf | `fuselage.scad` | Runde Nase → ausgebeultes, abgerundetes Rechteck → verjüngtes Heck |
| Leitwerk | `elliptic_tailplane.scad` | Höhenleitwerk NACA 0009, 2 Segmente |

Alle Teile spiegeln für die rechte Seite.

## Geschätztes Gewicht

| Komponente | Gewicht |
|---|---|
| Flügel (2 Hälften, gedruckt) | ~300 g |
| Rumpf + Leitwerk (gedruckt) | ~200 g |
| Motor + Regler (3S) | ~120 g |
| 3S LiPo 2200 mAh | ~180 g |
| Servos (4×) + Empfänger | ~80 g |
| Verbinder, Kabel, Misc | ~50 g |
| **Abfluggewicht (AUW)** | **~930 g** |
| **Flächenbelastung** | **~55 g/dm²** |

## Stückliste Zusatzmaterial

- Sekundenkleber / Epoxy für Segmentverbindungen
- RC-Komponenten: Motor (~1200 KV), Regler (30A), 4× Servo, Empfänger
- 3S LiPo 2200 mAh
- Propeller 10×7 oder 11×5.5
- Optional: CFK-Rundstab als Holm-Verstärkung

## Dateien

| Datei / Ordner | Beschreibung |
|---|---|
| `elliptic_wing.scad` | Geometrie-Kern („Bibliothek“): elliptische Slice-Architektur + Ruderlogik |
| `wing.scad` | Hauptflügel-Setup (konkrete Parameter) auf Basis von `elliptic_wing.scad` |
| `tailplane.scad` | Höhenleitwerks-Setup (NACA 0009, 480 mm, 2 Segmente) auf Basis von `elliptic_wing.scad` |
| `elliptic_tailplane.scad` | Kompatibilitäts-Wrapper auf `tailplane.scad` |
| `fuselage.scad` | Parametrischer Rumpf mit dünner Hülle + optionalen Innenrippen/Stringern |
| `assembly.scad` | Gesamtansicht (Explosions-/Zusammenbau, beide Seiten + Rumpf) |
| `calc_spar.py` | Hilfsskript für Holm-Berechnung |
| `print_segments/` | Druckfertige Segmente (Flügel, Querruder, Höhenleitwerk, Höhenruder) |

Rumpf-Hauptparameter in `fuselage.scad`:
- `fuselage_length` = Gesamtlänge
- `fuselage_width` = maximale Breite
- `fuselage_height` = maximale Höhe

## Druckeinstellungen (empfohlen)

- **Layer-Höhe**: 0.2 mm
- **Düse**: 0.4 mm
- **Perimeter**: 1 (Hülle ist bereits 0.4 mm im Modell!)
- **Infill**: 0% (Kreuzrippen sind im Modell enthalten!)
- **Material**: PLA oder LW-PLA (leichter)
- **Stützmaterial**: Keins nötig (Profil liegt auf der Unterseite)
- **Druckrichtung**: Flügel auf der Seite, Spannweite = Z-Achse

> ⚠️ Perimeter und Infill auf Minimum – die gesamte Struktur (Hülle, Rippen, Stege)
> ist bereits im Modell definiert. Der Slicer muss nur die vorgegebenen Konturen füllen.

## Status

🚧 **In Entwicklung**

- [x] Elliptischer Flügel (Per-Slice Architektur)
- [x] Kreuzrippen mit Erleichterungslöchern
- [x] Filament-Nuten
- [x] Querruder mit 30°-Bevel und Scharnierwänden
- [x] 5-Segment-Layout (druckfertig Adventurer 5M)
- [x] Querruder in 2 Segmente gesplittet
- [x] Assembly mit Explosionsansicht + Einstellwinkel
- [x] Rumpf-Grundform (station-basiert, dünnwandig, innen verstärkt)
- [ ] Servogruben im Querruder
- [ ] Segment-Steckverbindungen
- [x] Höhenleitwerk-Grundlayout (elliptisch, 2 Segmente, Höhenruder 0–200)
- [ ] Seitenleitwerk
- [ ] Motorhaube / Motorträger
- [ ] Fahrwerk
- [ ] Testflug 🛫
