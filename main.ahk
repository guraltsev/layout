#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Keyboard Layout Switcher with Math Input Modes
; ============================================================================
;
; This is the main entry point for the refactored layout switcher.
;
; Features:
;   - Multiple keyboard layouts (QWERTY, Colemak)
;   - Math input modes (LaTeX, Unicode symbols)
;   - Accent character composition
;   - Persistent settings via INI file
;   - Data-driven, extensible architecture
;
; Hotkeys:
;   - RControl + RShift: Cycle to next layout
;   - Backtick (in LaTeX/Unicode mode): Trigger math symbol input
;   - RAlt + ' : Acute accent composition
;   - RAlt + ` : Grave accent composition
;   - RAlt + ; : Diaeresis composition
;
; ============================================================================

SendMode("Input")  ; Optimizes for faster and more reliable input

; --- Library includes ---
#Include lib\OneShotMapper.ahk
#Include lib\AppState.ahk
#Include lib\ModeManager.ahk
#Include lib\LayoutManager.ahk
#Include lib\TrayUI.ahk

; --- Map includes (character mappings) ---
#Include maps\CharacterMaps.ahk
#Include maps\LaTeXMathInputMaps.ahk
#Include maps\UnicodeMathInputMaps.ahk

; --- Layout definitions ---
#Include layouts\Colemak.ahk

; --- Registry (must come after maps and layouts) ---
#Include lib\Registries.ahk

; ============================================================================
; INITIALIZATION
; ============================================================================

; Load application state
global state := AppState(A_ScriptDir "\config.ini")
state.Load()

; Build registries for layouts and modes
global registries := BuildRegistries()

; Create managers
global layoutMgr := LayoutManager(registries.layouts)
global modeMgr := ModeManager(registries.modes)

; Create accent mappers (active when Colemak is selected)
global accentMappers := BuildAccentMappers()

; Apply state function - called when state changes
ApplyState() {
    global layoutMgr, modeMgr, state, accentMappers

    ; Select layout
    layoutMgr.Select(state.layout)

    ; Enable/disable accent mappers based on layout
    ; Accent composition only makes sense with Colemak
    if (state.layout = "Colemak") {
        for mapper in accentMappers {
            mapper.Enable()
        }
    } else {
        for mapper in accentMappers {
            mapper.Disable()
        }
    }

    ; Select input mode
    modeMgr.Select(state.mode)
}

; Create and build tray UI
global tray := TrayUI(registries, state, ApplyState)
tray.Build()

; Apply state at startup
ApplyState()

; ============================================================================
; GLOBAL HOTKEYS
; ============================================================================

; Cycle to next layout with RControl + RShift
RControl & RShift:: {
    global state, registries, tray

    ; Get layout names as array
    layoutNames := []
    for name, def in registries.layouts {
        layoutNames.Push(name)
    }

    ; Find current index
    currentIdx := 1
    for idx, name in layoutNames {
        if (name = state.layout) {
            currentIdx := idx
            break
        }
    }

    ; Cycle to next
    nextIdx := currentIdx + 1
    if (nextIdx > layoutNames.Length) {
        nextIdx := 1
    }

    ; Update state via tray UI (handles save + apply + render)
    tray.SetLayout(layoutNames[nextIdx])
}

; ============================================================================
; KEEP SCRIPT RUNNING
; ============================================================================

Persistent(1)
