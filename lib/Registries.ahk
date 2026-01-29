; ==============================================================================
; Registries
; ------------------------------------------------------------------------------
; Responsibility:
;   Provide declarative registration for layouts and modes. This keeps all
;   “what exists” decisions in a single place and allows the rest of the app to
;   work generically over registries.
; ==============================================================================

; ------------------------------------------------------------------------------
; SendMath(text)
; Purpose:
;   Send math-mode output with a consistent, fast send strategy.
; Arguments:
;   text (string) - Text to emit (LaTeX or Unicode).
; Returns:
;   Nothing.
; ------------------------------------------------------------------------------
SendMath(text) {
    SetKeyDelay(-1)
    SendEvent(text)
}

; ------------------------------------------------------------------------------
; BuildRegistries()
; Purpose:
;   Construct and return the layout and mode registries.
; Arguments:
;   None.
; Returns:
;   object - { layouts: Map(), modes: Map() }
; ------------------------------------------------------------------------------
BuildRegistries() {
    regs := {}
    regs.layouts := Map()
    regs.modes := Map()

    regs.layouts["Colemak"] := ColemakLayoutDef()
    regs.layouts["None"] := {
        name: "None",
        abbr: "None",
        icon: "icons/default.ico",
        remaps: Map()
    }

    regs.modes["off"] := {
        name: "Off",
        abbr: "Off",
        Enable: (*) => 0,
        Disable: (*) => 0
    }

    latexMapper := OneShotMapper("SC029", LaTeXMathMap, SendMath)
    regs.modes["latex"] := {
        name: "LaTeX",
        abbr: "TeX",
        Enable: (*) => latexMapper.Enable(),
        Disable: (*) => latexMapper.Disable()
    }

    unicodeMapper := OneShotMapper("SC029", UnicodeMathMap, SendMath)
    regs.modes["unicode"] := {
        name: "Unicode",
        abbr: "Uni",
        Enable: (*) => unicodeMapper.Enable(),
        Disable: (*) => unicodeMapper.Disable()
    }

    return regs
}
