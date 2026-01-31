#Requires AutoHotkey v2.0

; AppState - Centralized state management with persistence
;
; This class owns all application state and provides:
;   - Single source of truth for layout, mode, debug settings
;   - INI-based persistence (load on startup, save on change)
;   - Clean API for state access and modification
;
; Usage:
;   state := AppState(A_ScriptDir "\config.ini")
;   state.Load()
;   state.layout := "Colemak"
;   state.Save()

class AppState {
    ; Constructor
    ; configPath - Path to the INI configuration file
    __New(configPath) {
        this.configPath := configPath

        ; Default values
        this.layout := "QWERTY"      ; Current layout name
        this.mode := "off"           ; "off" | "latex" | "unicode"
        this.debug := false          ; Debug mode toggle
    }

    ; Load state from INI file
    ; Silently uses defaults if file doesn't exist
    Load() {
        if !FileExist(this.configPath)
            return

        try {
            this.layout := IniRead(this.configPath, "State", "Layout", this.layout)
            this.mode := IniRead(this.configPath, "State", "Mode", this.mode)
            this.debug := IniRead(this.configPath, "State", "Debug", this.debug ? 1 : 0) = 1
        }
    }

    ; Save current state to INI file
    Save() {
        try {
            IniWrite(this.layout, this.configPath, "State", "Layout")
            IniWrite(this.mode, this.configPath, "State", "Mode")
            IniWrite(this.debug ? 1 : 0, this.configPath, "State", "Debug")
        }
    }
}
