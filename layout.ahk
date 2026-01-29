#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; Layout — Modular Keyboard Layout & Input Mode Manager (AutoHotkey v2)
;
; OVERVIEW
; -------
; This script provides a modular, data-driven keyboard layout switcher with
; optional one-shot input modes (e.g., LaTeX or Unicode math) and compose
; mappings (e.g., accent composition). The core goals are:
;   - Centralize state (selected layout/mode) to reduce duplication.
;   - Make layouts/modes registry-based so adding new capabilities is declarative.
;   - Keep input capture logic reusable through a single OneShotMapper class.
;
; ARCHITECTURE
; -----------
; 1) AppState (lib/AppState.ahk)
;    - Owns persisted state: layout, mode, debug flag, config path.
;    - Provides Load/Save for INI-based persistence.
;
; 2) Registries (lib/Registries.ahk)
;    - Declarative registration of layouts and modes.
;    - Layouts are data objects (name/icon/remaps/extras).
;    - Modes are data objects (name/Enable/Disable).
;
; 3) LayoutManager (lib/LayoutManager.ahk)
;    - Enables/disables layout hotkeys based on the selected layout.
;    - Manages “extras” (e.g., compose mappers) tied to a layout.
;
; 4) ModeManager (lib/ModeManager.ahk)
;    - Enforces a single active input mode.
;    - Activates/deactivates OneShotMapper instances for modes.
;
; 5) OneShotMapper (lib/OneShotMapper.ahk)
;    - Reusable “capture next input → map → send” component.
;    - Used for LaTeX/Unicode math input and accent composition.
;
; 6) TrayUI (lib/TrayUI.ahk)
;    - Builds the tray menu from registries.
;    - Renders the current state (checks, icon, tooltip).
;
; DATA FLOW / LIFECYCLE
; ---------------------
; Startup:
;   - Load AppState from config.ini (if present).
;   - Build registries for layouts and modes.
;   - Create managers and tray UI.
;   - Apply state once: LayoutManager + ModeManager.
;
; User actions:
;   - Tray selection updates AppState (layout/mode).
;   - ApplyState reconfigures hotkeys/modes.
;   - TrayUI renders checks, icon, tooltip.
;
; EXTENDING THE APP
; -----------------
; Add a new layout:
;   1) Create a layout definition (e.g., layouts/NewLayout.ahk).
;   2) Register it in BuildRegistries().
;
; Add a new input mode:
;   1) Define a map in maps or use existing map files.
;   2) Create a OneShotMapper instance in BuildRegistries().
;   3) Add a registry entry with Enable/Disable.
;
; This file serves as the entry point that wires modules together.
; ==============================================================================

SendMode("Input")

#Include lib\AppState.ahk
#Include lib\OneShotMapper.ahk
#Include lib\LayoutManager.ahk
#Include lib\ModeManager.ahk
#Include lib\Registries.ahk
#Include lib\TrayUI.ahk

#Include CharacterMaps.ahk
#Include LaTeXMathInputMaps.ahk
#Include UnicodeMathInputMaps.ahk
#Include layouts\Colemak.ahk

state := AppState(A_ScriptDir "\config.ini")
state.Load()

registries := BuildRegistries()
layoutMgr := LayoutManager(registries.layouts)
modeMgr := ModeManager(registries.modes)

; ------------------------------------------------------------------------------
; ApplyState(*)
; Purpose:
;   Apply the current AppState to managers (layout + mode).
; Arguments:
;   * (ignored) - Callback compatibility; no inputs expected.
; Returns:
;   Nothing.
; ------------------------------------------------------------------------------
ApplyState := (*) => (
    layoutMgr.Select(state.layout),
    modeMgr.Select(state.mode)
)

tray := TrayUI(registries, state, ApplyState)
tray.Build()
ApplyState()
tray.Render(state)

return
