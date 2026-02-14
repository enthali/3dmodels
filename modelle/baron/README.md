# Baron – 1920er Schulterdecker RC-Modell

## Beschreibung

RC-Modellflugzeug inspiriert von Schulterdeckern der 1920er Jahre.
Parametrisches Design, mehrteilig für FDM-Druck optimiert.

## Technische Daten

| Parameter | Wert |
|---|---|
| Spannweite | 1000 mm |
| Rumpflänge | 700 mm |
| Flügelprofil | NACA 4415 |
| Leitwerksprofil | NACA 0009 |
| Bauweise | Hohlschale, FDM-optimiert |
| Wandstärke | 1.6 mm |
| Flügelholm | 6 mm Carbonrohr |

## Zielmaschine

**FlashForge Adventurer 5M** (220 × 220 × 220 mm)

### Segmentierung

Das Modell wird automatisch in druckbare Segmente aufgeteilt:

- **Rumpf**: ~4 Segmente (je ~175 mm)
- **Flügel**: ~3 Segmente pro Seite (je ~153 mm)
- **Leitwerk**: je 1 Teil
- **Motorhaube**: 1 Teil

## Stückliste Zusatzmaterial

- Carbonrohr 6 mm × 500+ mm (Flügelholm, 2×)
- Carbonrohr 8 mm × 700 mm (Rumpfholm)
- Sekundenkleber / Epoxy für Verbindungen
- RC-Komponenten (Motor, Servos, Empfänger, Regler, Akku)

## Dateien

| Datei / Ordner | Beschreibung |
|---|---|
| `elliptic_wing.scad` | Hauptdesign – elliptischer Flügel (NACA 4415, DC-3-Planform) |
| `assembly.scad` | Gesamtansicht (beide Halbflügel + Rumpf-Platzhalter) |
| `calc_spar.py` | Hilfsskript für Holm-Berechnung |
| `print_segments/` | Druckfertige Flügelsegmente (6× .scad + STLs) |
| `legacy/` | Ältere Entwürfe (Original-Baron, einfaches Rippensegment) |
| `test_grooves.scad` | Test/Debug für Filament-Rillen |

## Druckeinstellungen (empfohlen)

- Layer-Höhe: 0.2 mm
- Perimeter: 4 (= 1.6 mm Wand)
- Infill: 10–15% (Gyroid oder Lines)
- Material: PLA oder LW-PLA (leichter!)
- Stützmaterial: Nur wo nötig (Flügelunterkante)

## Status

🚧 **In Entwicklung** – Erster Entwurf, noch nicht testgeflogen.
