; ==============================================================================
; AppState
; ------------------------------------------------------------------------------
; Responsibility:
;   Owns the persistent application state (current layout, mode, debug flag).
;   Provides simple INI-based persistence so the last selection is restored
;   on startup.
; ==============================================================================
class AppState {
    ; ----------------------------------------------------------------------------
    ; __New(configPath)
    ; Purpose:
    ;   Construct an AppState with defaults and a target INI path.
    ; Arguments:
    ;   configPath (string) - Full path to the INI file used for persistence.
    ; Returns:
    ;   AppState instance.
    ; ----------------------------------------------------------------------------
    __New(configPath) {
        this.configPath := configPath
        this.layout := "Colemak"
        this.mode := "unicode"
        this.debug := false
    }

    ; ----------------------------------------------------------------------------
    ; Load()
    ; Purpose:
    ;   Read persisted state from the INI file if it exists.
    ; Arguments:
    ;   None.
    ; Returns:
    ;   Nothing. Updates instance properties in-place.
    ; ----------------------------------------------------------------------------
    Load() {
        if !FileExist(this.configPath)
            return
        this.layout := IniRead(this.configPath, "State", "Layout", this.layout)
        this.mode := IniRead(this.configPath, "State", "Mode", this.mode)
        this.debug := IniRead(this.configPath, "State", "Debug", this.debug ? 1 : 0) = 1
    }

    ; ----------------------------------------------------------------------------
    ; Save()
    ; Purpose:
    ;   Persist current state to the INI file.
    ; Arguments:
    ;   None.
    ; Returns:
    ;   Nothing. Writes properties to disk.
    ; ----------------------------------------------------------------------------
    Save() {
        IniWrite(this.layout, this.configPath, "State", "Layout")
        IniWrite(this.mode, this.configPath, "State", "Mode")
        IniWrite(this.debug ? 1 : 0, this.configPath, "State", "Debug")
    }
}
