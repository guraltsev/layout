#Requires AutoHotkey v2.0

; Registries - Centralized registration for layouts and modes
;
; This file provides a single place to register all layouts and input modes.
; Adding a new layout or mode is a one-liner change here.
;
; Usage:
;   registries := BuildRegistries()
;   ; registries.layouts -> Map of layout name -> definition
;   ; registries.modes -> Map of mode name -> definition

BuildRegistries() {
    regs := {}
    regs.layouts := Map()
    regs.modes := Map()

    ; ========================================
    ; LAYOUTS
    ; ========================================

    ; QWERTY layout (no remaps - default keyboard)
    regs.layouts["QWERTY"] := {
        name: "QWERTY",
        abbr: "QW",
        icon: "icons/default.ico",
        remaps: Map()  ; No remaps for default layout
    }

    ; Colemak layout (from layouts/Colemak.ahk)
    regs.layouts["Colemak"] := ColemakLayoutDef()

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
    global _latexMapper := OneShotMapper("SC029", LaTeXMathMap, SendText)
    regs.modes["latex"] := {
        name: "LaTeX",
        abbr: "TeX",
        Enable: (*) => _latexMapper.Enable(),
        Disable: (*) => _latexMapper.Disable()
    }

    ; Unicode math mode - backtick + key -> Unicode symbol
    global _unicodeMapper := OneShotMapper("SC029", UnicodeMathMap, SendText)
    regs.modes["unicode"] := {
        name: "Unicode",
        abbr: "Uni",
        Enable: (*) => _unicodeMapper.Enable(),
        Disable: (*) => _unicodeMapper.Disable()
    }

    return regs
}

; Build accent compose mappers for a layout
; Returns an array of OneShotMapper instances
BuildAccentMappers() {
    mappers := []

    ; RAlt + ' (quote key) -> Acute accents
    mappers.Push(OneShotMapper(">!SC028", AcuteAccentMap, SendText))

    ; RAlt + ` (backtick) -> Grave accents
    mappers.Push(OneShotMapper(">!SC029", GraveAccentMap, SendText))

    ; RAlt + ; (semicolon, which is p in Colemak) -> Diaeresis
    mappers.Push(OneShotMapper(">!SC019", DiaeresisMap, SendText))

    return mappers
}
