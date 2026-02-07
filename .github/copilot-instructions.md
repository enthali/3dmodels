# Copilot Instructions – 3D-Modell-Werkstatt

## Überblick

Dieses Workspace dient der gemeinsamen Erstellung von 3D-Modellen für CNC-Fräsen und 3D-Druck.
Wir arbeiten primär mit **OpenSCAD** (`.scad`-Dateien) und **Autodesk Fusion 360** (via MCP-Server).

---

## Maschinen & Bauräume

### CNC-Fräse

| Maschine | Arbeitsbereich (X×Y×Z) | Spindel | Hinweise |
|---|---|---|---|
| **Stepcraft 420** | 300 × 420 × 78 mm | HF-Spindel / Kress | Fräsen, Gravieren, Bohren; Z-Hub begrenzt! |

### 3D-Drucker (Resin / MSLA)

| Drucker | Bauraum (X×Y×Z) | Technologie | Layer-Höhe | Hinweise |
|---|---|---|---|---|
| **Elegoo Mars** | 120 × 68 × 155 mm | MSLA (UV-Resin) | 0.02–0.05 mm | Feine Details, kleiner Bauraum |
| **Elegoo Saturn** | 192 × 120 × 200 mm | MSLA (UV-Resin) | 0.02–0.05 mm | Größerer Bauraum, hochauflösend |

### 3D-Drucker (FDM / Filament)

| Drucker | Bauraum (X×Y×Z) | Technologie | Düse | Hinweise |
|---|---|---|---|---|
| **FlashForge Adventurer 5M** | 220 × 220 × 220 mm | FDM (PLA/PETG/ABS) | 0.4 mm Standard | Schnell, enclosed, gute erste Wahl für Prototypen |

---

## Werkzeuge & Workflow

### OpenSCAD (.scad-Dateien)

- **Hauptwerkzeug** für parametrische Modelle
- Dateien liegen im Workspace und sind versionierbar (Git-freundlich)
- Export: `.stl` (für Slicer) und `.step` / `.dxf` (für Fusion 360 / CNC)
- OpenSCAD wird über Terminal aufgerufen (`openscad` CLI)

#### OpenSCAD-Konventionen

```scad
// Einheiten: immer Millimeter (mm)
// $fn für Kreisauflösung:
//   - Vorschau/Entwicklung: $fn = 32
//   - Export/Produktion:    $fn = 128 oder höher

// Parameter am Dateianfang als Variablen definieren:
width  = 40;   // [mm]
height = 20;   // [mm]
depth  = 10;   // [mm]
wall   = 2.0;  // [mm] Wandstärke

// Module benennen nach Funktion:
module gehaeuse(w, h, d, wall) { ... }
```

**Richtlinien für .scad-Dateien:**

1. **Parametrisch** – Alle Maße als Variablen am Dateianfang
2. **Modular** – Wiederverwendbare `module`-Blöcke
3. **Kommentiert** – Deutsch oder Englisch, klar beschreiben was jedes Modul tut
4. **Druckbar/Fräsbar** – Überhänge, Wandstärken und Toleranzen beachten:
   - FDM: Min. Wandstärke 1.2 mm (3× Düse), Überhang max ~45°
   - Resin: Min. Wandstärke 0.8 mm, filigrane Details möglich
   - CNC: Innenradien ≥ Fräser-Radius, Zugang für Werkzeug beachten
5. **Maschinen-Validierung** – Fertige Modelle gegen Bauräume prüfen

### Fusion 360 (via MCP-Server)

- Verfügbar über `mcp_mypc_fusion360` (AuraFriday MCP-Link)
- Fusion 360 muss lokal laufen mit aktivem MCP-Link Add-In
- **Fusion als Ergänzung**: Komplexe Freiformflächen, CAM-Toolpaths, STEP-Import/Export
- **Koordinatensystem**: Y ist OBEN in Fusion 360!

#### Typische Fusion-Operationen via MCP

- Sketch erstellen und extrudieren
- STEP/STL importieren (z.B. aus OpenSCAD exportiert)
- CAM-Toolpaths für Stepcraft generieren
- Parametrische Designs mit User-Parameters

### Zusammenspiel OpenSCAD ↔ Fusion 360

```
 .scad (parametrisch, im Repo)
    │
    ├──► openscad -o modell.stl modell.scad     → STL für Slicer
    ├──► openscad -o modell.step modell.scad    → STEP für Fusion (falls unterstützt)
    └──► openscad -o modell.dxf modell.scad     → DXF für 2D CNC-Fräsen
                                                     │
                                                     ▼
                                              Fusion 360 (MCP)
                                              CAM / Nachbearbeitung
```

---

## Projektstruktur

Die Struktur ist **modell-zentriert** – jedes Projekt bekommt einen eigenen Ordner.
Maschinenspezifische Unterordner (z.B. `fdm/`, `resin/`, `stepcraft/`) werden nur bei Bedarf angelegt.

```
3dmodels/
├── .github/
│   └── copilot-instructions.md     ← diese Datei
├── .vscode/
│   └── mcp.json                    ← MCP-Server-Konfiguration
├── lib/                            ← Gemeinsame OpenSCAD-Bibliotheken
│   ├── hardware.scad               ← Schrauben, Muttern, Inserts
│   ├── airfoil.scad                ← Tragflächenprofile (NACA etc.)
│   ├── connectors.scad             ← Steckverbindungen für mehrteilige Drucke
│   ├── rounded.scad                ← Abgerundete Ecken/Kanten
│   └── tolerances.scad             ← Druckertoleranzen & Passungen
├── modelle/
│   └── <projektname>/              ← ein Modell-Projekt
│       ├── <name>.scad             ← Hauptdatei (parametrisch)
│       ├── <teil>.scad             ← Weitere Teile / Module
│       ├── README.md               ← Beschreibung, Maße, Zielmaschine
│       ├── fdm/                    ← FDM-spezifische Exports (optional)
│       ├── resin/                  ← Resin-spezifische Exports (optional)
│       └── stepcraft/              ← CNC-spezifische Exports (optional)
└── .gitignore
```

---

## Workflow-Anweisungen für Copilot

### Beim Erstellen eines neuen Modells:

1. **Frage nach Zielmaschine** (Stepcraft / Mars / Saturn / Adventurer 5M)
2. **Prüfe Bauraum** – Modell muss in den Bauraum der Zielmaschine passen
3. **Erstelle .scad-Datei** im passenden Unterordner
4. **Parametrisch aufbauen** – Alle Maße als Variablen
5. **STL exportieren** via `openscad` CLI wenn gewünscht
6. **Fusion 360 Sync** – Bei Bedarf Modell via MCP in Fusion 360 verfügbar machen

### Beim Arbeiten mit Fusion 360 (MCP):

1. Verwende `execute_python` für komplexe Operationen
2. Nutze `PTransaction` für atomare Undo-Gruppen
3. Speichere Zwischenergebnisse mit `store_as`
4. Y-Achse = OBEN (Fusion-Koordinatensystem)
5. Einheiten in Fusion: **cm** intern (1 cm = 10 mm) – bei Maßeingabe beachten!

### Design-Richtlinien nach Fertigungsverfahren:

#### FDM (Adventurer 5M)
- Wandstärke: ≥ 1.2 mm (bei 0.4 mm Düse)
- Überhänge: ≤ 45° ohne Stützmaterial
- Brücken: ≤ 50 mm Spannweite
- Toleranz für Passungen: +0.2 mm (Loch) / -0.1 mm (Zapfen)
- Layer-Höhe typisch: 0.2 mm (Standard), 0.12 mm (Fein)

#### Resin (Mars / Saturn)
- Wandstärke: ≥ 0.8 mm
- Aushöhlen bei großen Volumina (Resin sparen, Warping reduzieren)
- Drainlöcher für hohle Teile (≥ 2 mm)
- Stützen beachten: Inseln und extreme Überhänge vermeiden
- Ausrichtung auf der Platte beeinflusst Qualität stark

#### CNC-Fräsen (Stepcraft 420)
- Innenradien ≥ Fräser-Radius (typisch ≥ 1.5 mm bei 3 mm Fräser)
- Keine Hinterschnitte (3-Achs-Fräse)
- Materialtiefe ≤ 78 mm (Z-Hub)
- Aufspannung und Haltestege einplanen
- 2D-Profile: DXF exportieren

---

## Nützliche OpenSCAD-CLI-Befehle

```powershell
# STL exportieren (für Slicer)
openscad -o output.stl -D "$fn=128" modell.scad

# PNG-Vorschau rendern
openscad -o preview.png --imgsize=800,600 modell.scad

# DXF exportieren (2D-Projektion für CNC)
openscad -o output.dxf modell.scad

# Mit benutzerdefinierten Parametern
openscad -o output.stl -D "width=50" -D "height=30" modell.scad
```

---

## Sprache & Kommunikation

- Kommunikation auf **Deutsch** bevorzugt
- Code-Kommentare: Deutsch oder Englisch (konsistent pro Datei)
- Variablennamen: Englisch (OpenSCAD-Konvention)
- Dateinamen: Englisch, lowercase, mit Bindestrichen (`kabelhalter.scad`, `tool-holder.scad`)

---

## Checkliste vor Fertigstellung

- [ ] Modell passt in Bauraum der Zielmaschine
- [ ] Parametrisch (keine Magic Numbers)
- [ ] Fertigungsgerechte Wandstärken und Toleranzen
- [ ] STL exportiert und geprüft (manifold, keine Lücken)
- [ ] README.md im Projektordner mit Beschreibung
