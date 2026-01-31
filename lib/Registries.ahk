#Requires AutoHotkey v2.0

; Registries - Centralized registration for layouts and modes
;
; This file provides a single place to register all layouts and input modes.
; Layouts and maps are loaded from INI config files at runtime, with fallback
; to hardcoded defaults if config files don't exist.
;
; Usage:
;   loader := ConfigLoader(A_ScriptDir "\config")
;   registries := BuildRegistries(loader)
;   ; registries.layouts -> Map of layout name -> definition
;   ; registries.modes -> Map of mode name -> definition
;
; Config file structure:
;   config/
;     layouts/
;       QWERTY.ini
;       Colemak.ini
;     maps/
;       acute.ini
;       grave.ini
;       diaeresis.ini
;       latex.ini
;       unicode.ini

BuildRegistries(loader := "") {
    regs := {}
    regs.layouts := Map()
    regs.modes := Map()

    ; ========================================
    ; LAYOUTS - Load from config or use defaults
    ; ========================================

    layoutsLoaded := false
    if (loader != "" && loader.HasConfig()) {
        configLayouts := loader.LoadLayouts()
        if (configLayouts.Count > 0) {
            regs.layouts := configLayouts
            layoutsLoaded := true
        }
    }

    ; Fallback to hardcoded layouts if no config
    if (!layoutsLoaded) {
        ; QWERTY layout (no remaps - default keyboard)
        regs.layouts["QWERTY"] := {
            name: "QWERTY",
            abbr: "QW",
            icon: "icons/default.ico",
            remaps: Map()
        }

        ; Colemak layout (from layouts/Colemak.ahk)
        regs.layouts["Colemak"] := ColemakLayoutDef()
    }

    ; ========================================
    ; MAPS - Load from config or use defaults
    ; ========================================

    ; Try to load maps from config
    latexMap := ""
    unicodeMap := ""

    if (loader != "" && loader.HasConfig()) {
        latexMap := loader.LoadMap("latex")
        unicodeMap := loader.LoadMap("unicode")
    }

    ; Fallback to hardcoded maps if empty
    if (latexMap = "" || latexMap.Count = 0)
        latexMap := LaTeXMathMap
    if (unicodeMap = "" || unicodeMap.Count = 0)
        unicodeMap := UnicodeMathMap

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

; Build accent compose mappers for a layout
; loader - Optional ConfigLoader instance for loading maps from config
; Returns an array of OneShotMapper instances
BuildAccentMappers(loader := "") {
    mappers := []

    ; Try to load maps from config
    acuteMap := ""
    graveMap := ""
    diaeresisMap := ""

    if (loader != "" && loader.HasConfig()) {
        acuteMap := loader.LoadMap("acute")
        graveMap := loader.LoadMap("grave")
        diaeresisMap := loader.LoadMap("diaeresis")
    }

    ; Fallback to hardcoded maps if empty
    if (acuteMap = "" || acuteMap.Count = 0)
        acuteMap := AcuteAccentMap
    if (graveMap = "" || graveMap.Count = 0)
        graveMap := GraveAccentMap
    if (diaeresisMap = "" || diaeresisMap.Count = 0)
        diaeresisMap := DiaeresisMap

    ; RAlt + ' (quote key) -> Acute accents
    mappers.Push(OneShotMapper(">!SC028", acuteMap, SendText))

    ; RAlt + ` (backtick) -> Grave accents
    mappers.Push(OneShotMapper(">!SC029", graveMap, SendText))

    ; RAlt + ; (semicolon, which is p in Colemak) -> Diaeresis
    mappers.Push(OneShotMapper(">!SC019", diaeresisMap, SendText))

    return mappers
}
