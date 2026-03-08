#Requires AutoHotkey v2.0

; Registries - Centralized registration for layouts and modes
;
; This file provides a single place to register all layouts and input modes.
; Layouts and maps are loaded from INI config files at runtime.
;
; Usage:
;   loader := ConfigLoader(A_ScriptDir "\config")
;   registries := BuildRegistries(loader)
;   ; registries.layouts -> Map of layout name -> definition
;   ; registries.modes   -> Map of mode name -> definition
;
; Expected config structure:
;   config/
;     layouts/
;       *.ini
;     maps/
;       latex.ini
;       unicode.ini
;       acute.ini
;       grave.ini
;       diaeresis.ini

BuildRegistries(loader) {
    if (loader = "")
        throw Error("ConfigLoader instance is required.")

    regs := {}
    regs.layouts := Map()
    regs.modes := Map()

    ; ========================================
    ; LAYOUTS
    ; ========================================

    regs.layouts := loader.LoadLayouts()
    if (regs.layouts.Count = 0) {
        throw Error(
            "No layouts loaded from: " loader.layoutsDir
            . "`nAdd at least one .ini file under config/layouts/ with a [Layout] section."
        )
    }

    ; ========================================
    ; MAPS (Math input)
    ; ========================================

    latexMap := loader.LoadMap("latex")
    if (latexMap.Count = 0)
        throw Error("Required map missing or empty: " loader.mapsDir "\latex.ini")

    unicodeMap := loader.LoadMap("unicode")
    if (unicodeMap.Count = 0)
        throw Error("Required map missing or empty: " loader.mapsDir "\unicode.ini")

    ; ========================================
    ; MODES (Input modes)
    ; ========================================

    ; Off mode (no special input handling)
    regs.modes["off"] := {
        name: "Off",
        abbr: "Off",
        Enable: (*) => 0,
        Disable: (*) => 0
    }

    ; LaTeX math mode - backtick + key -> LaTeX command
    global _latexMapper := OneShotMapper("SC029", latexMap, SendText)
    regs.modes["latex"] := {
        name: "LaTeX",
        abbr: "TeX",
        Enable: (*) => _latexMapper.Enable(),
        Disable: (*) => _latexMapper.Disable()
    }

    ; Unicode math mode - backtick + key -> Unicode symbol
    global _unicodeMapper := OneShotMapper("SC029", unicodeMap, SendText)
    regs.modes["unicode"] := {
        name: "Unicode",
        abbr: "Uni",
        Enable: (*) => _unicodeMapper.Enable(),
        Disable: (*) => _unicodeMapper.Disable()
    }

    return regs
}

; Build accent compose mappers.
; Returns an array of OneShotMapper instances.
BuildAccentMappers(loader) {
    if (loader = "")
        throw Error("ConfigLoader instance is required.")

    mappers := []

    acuteMap := loader.LoadMap("acute")
    if (acuteMap.Count = 0)
        throw Error("Required map missing or empty: " loader.mapsDir "\acute.ini")

    graveMap := loader.LoadMap("grave")
    if (graveMap.Count = 0)
        throw Error("Required map missing or empty: " loader.mapsDir "\grave.ini")

    diaeresisMap := loader.LoadMap("diaeresis")
    if (diaeresisMap.Count = 0)
        throw Error("Required map missing or empty: " loader.mapsDir "\diaeresis.ini")

    ; RAlt + ' (quote key) -> Acute accents
    mappers.Push(OneShotMapper(">!SC028", acuteMap, SendText))

    ; RAlt + ` (backtick) -> Grave accents
    mappers.Push(OneShotMapper(">!SC029", graveMap, SendText))

    ; RAlt + ; (semicolon, which is p in Colemak) -> Diaeresis
    mappers.Push(OneShotMapper(">!SC019", diaeresisMap, SendText))

    return mappers
}
