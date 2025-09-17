# 🚗 Swusku Advanced Vehicle Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FiveM](https://img.shields.io/badge/FiveM-Compatible-blue.svg)](https://fivem.net/)
[![ESX](https://img.shields.io/badge/ESX-Legacy-green.svg)](https://github.com/esx-framework/esx-legacy)
[![QB-Core](https://img.shields.io/badge/QB--Core-Compatible-blue.svg)](https://github.com/qbcore-framework/qb-core)

Ein fortschrittliches Fahrzeugverwaltungssystem für FiveM mit mehrsprachiger Unterstützung, Framework-Flexibilität und automatischem Update-Checker.

## 🌟 Features

### 🔧 Fahrzeugsteuerung
- **Verriegelung**: Fahrzeug sperren/entsperren mit Tastenkürzel oder Menü
- **Motor**: Motor an/aus schalten mit visuellen und akustischen Effekten
- **Beleuchtung**: Scheinwerfer ein/ausschalten
- **Fenster**: Individuelle Fenstersteuerung (hoch/runter)
- **Türen**: Alle Türen einzeln öffnen/schließen (inkl. Motorhaube & Kofferraum)
- **Blinker**: Linker/rechter Blinker und Warnblinker
- **Geschwindigkeitsbegrenzer**: Dynamischer Speed Limiter
- **Tempomat**: Cruise Control System

### 🌍 Mehrsprachigkeit
- **Deutsch** (de.json)
- **Englisch** (en.json) 
- **Russisch** (ru.json)
- **Japanisch** (ja.json)

### 🔄 Update System
- Automatischer Update-Checker über GitHub API
- Benachrichtigungen für Administratoren
- Konfigurierbare Update-Intervalle
- Versionsverwaltung

### 🔧 Framework-Kompatibilität
- **ESX Legacy**: Vollständige Unterstützung
- **QB-Core**: Vollständige Unterstützung
- **Einfacher Wechsel**: Nur eine Zeile in der config.lua ändern
- **Automatische Erkennung**: Framework wird automatisch initialisiert

### 🎨 Moderne UI
- Responsive Design mit dunklem Theme
- Animierte Buttons und Übergänge
- Tastenkürzel-Anzeige
- Status-Indikatoren für alle Features

## 📦 Installation

1. **Download**: Lade das Script herunter und entpacke es
2. **Platzierung**: Kopiere den Ordner `swusku_vehiclemanager` in deinen `resources` Ordner
3. **Server.cfg**: Füge `ensure swusku_vehiclemanager` zu deiner server.cfg hinzu
4. **Restart**: Starte deinen Server neu

## ⚙️ Konfiguration

Die Konfiguration erfolgt über die `config.lua` Datei:

```lua
Config = {}

-- Framework wählen
Config.Framework = 'ESX' -- 'ESX' oder 'QB' (QB-Core)

-- Sprache einstellen
Config.Locale = 'de' -- de, en, ru, ja

-- Update Checker
Config.UpdateCheck = {
    enabled = true,
    repository = 'SwuskuRP/swusku_vehiclemanager',
    checkInterval = 3600000, -- 1 Stunde
    currentVersion = '1.0.0'
}

-- Tastenbelegung
Config.Keys = {
    vehicleMenu = 'F6',
    lockVehicle = 'U',
    engine = 'G',
    lights = 'L'
}
```

### Framework wechseln
Um zwischen ESX und QB-Core zu wechseln, ändere einfach diese Zeile:
```lua
Config.Framework = 'QB' -- Für QB-Core
-- oder
Config.Framework = 'ESX' -- Für ESX Legacy
```

## 🎮 Steuerung

### Tastenkürzel
- **F6**: Fahrzeug-Menü öffnen/schließen
- **U**: Fahrzeug sperren/entsperren
- **G**: Motor an/aus
- **L**: Lichter an/aus
- **Q**: Linker Blinker
- **E**: Rechter Blinker
- **X**: Warnblinker

### Menü-Navigation
- Nutze das F6-Menü für erweiterte Funktionen
- Alle Buttons sind mit Icons und Beschreibungen versehen
- Status-Anzeigen zeigen den aktuellen Zustand

## 🔧 Erweiterte Features

### Berechtigungen
```lua
Config.Permissions = {
    adminOnly = false, -- Nur für Admins
    jobRestricted = false, -- Job-Beschränkung
    allowedJobs = {'police', 'ambulance', 'mechanic'}
}
```

### Fahrzeugklassen
```lua
Config.AllowedVehicleClasses = {
    [0] = true,  -- Kompaktwagen
    [1] = true,  -- Limousinen
    [8] = true,  -- Motorräder
    [13] = false, -- Fahrräder (deaktiviert)
    -- ... weitere Klassen
}
```

## 🌐 Mehrsprachigkeit hinzufügen

1. Erstelle eine neue JSON-Datei in `locales/` (z.B. `fr.json`)
2. Kopiere die Struktur von `en.json`
3. Übersetze alle Texte
4. Füge die Sprache zur `config.lua` hinzu

Beispiel für Französisch:
```json
{
  "vehicle_locked": "🔒 Véhicule verrouillé",
  "vehicle_unlocked": "🔓 Véhicule déverrouillé",
  ...
}
```

## 🔄 Update Checker

Das Script überprüft automatisch auf GitHub nach Updates:

- **Automatisch**: Alle 60 Minuten (konfigurierbar)
- **Manuell**: `/checkupdates` Befehl (nur Admins)
- **Benachrichtigungen**: Nur Administratoren erhalten Update-Meldungen

## 🎨 UI Anpassung

### Themes
Die UI unterstützt verschiedene Themes über CSS:
- **Dark Theme** (Standard)
- **Light Theme** (in config.lua aktivierbar)

### Positionen
```lua
Config.UI = {
    position = 'top-right', -- top-left, top-right, bottom-left, bottom-right
    theme = 'dark',
    showKeybinds = true,
    animationSpeed = 300
}
```

## 🔊 Sound System

```lua
Config.Sounds = {
    enabled = true,
    lockSound = 'car_lock',
    unlockSound = 'car_unlock',
    volume = 0.5
}
```

## 🐛 Debugging

Aktiviere den Debug-Modus für detaillierte Logs:
```lua
Config.Debug = true
```

## 📋 Kompatibilität

- **FiveM**: Alle aktuellen Versionen
- **ESX**: Legacy Framework (vollständig unterstützt)
- **QB-Core**: Alle aktuellen Versionen (vollständig unterstützt)
- **Lua**: 5.4 (lua54 'yes')
- **Browser**: Moderne Browser (Chrome, Firefox, Edge)

### Framework-spezifische Features
- **ESX**: Nutzt ESX.ShowNotification, ESX Gruppen-System
- **QB-Core**: Nutzt QBCore.Functions.Notify, QB Permissions-System
- **Automatische Erkennung**: Das Script erkennt automatisch welches Framework verwendet wird

## 🤝 Support & Contribution

### Bug Reports
Erstelle ein Issue auf GitHub mit:
- FiveM Version
- ESX Version
- Fehlerbeschreibung
- Console Logs

### Feature Requests
Gerne kannst du neue Features vorschlagen!

### Pull Requests
Contributions sind willkommen:
1. Fork das Repository
2. Erstelle einen Feature Branch
3. Committe deine Änderungen
4. Erstelle einen Pull Request

## 📄 Lizenz

Dieses Projekt steht unter der [MIT Lizenz](LICENSE).

## 👥 Credits

- **Entwicklung**: Swusku Development Team
- **UI Design**: Moderne Material Design Prinzipien
- **Icons**: Font Awesome 6.0
- **Inspiration**: FiveM Community

## 🔗 Links

- **GitHub**: [SwuskuRP/swusku_vehiclemanager](https://github.com/SwuskU/swusku_vehiclemanager)

---

**Viel Spaß mit dem Swusku Advanced Vehicle Manager! 🚗✨**
