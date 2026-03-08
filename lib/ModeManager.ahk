#Requires AutoHotkey v2.0

; ModeManager - Manages input mode switching (off, latex, unicode)
;
; This class enforces mutual exclusion between input modes.
; Only one mode can be active at a time.
;
; Usage:
;   modeMgr := ModeManager(modeRegistry)
;   modeMgr.Select("latex")

class ModeManager {
    ; Constructor
    ; modeRegistry - Map of mode name -> mode definition object
    ;   Each mode definition should have:
    ;     - name: Display name
    ;     - Enable: Callback function to enable the mode
    ;     - Disable: Callback function to disable the mode
    __New(modeRegistry) {
        this.registry := modeRegistry
        this.active := "off"
    }

    ; Select and activate a mode
    ; name - The mode name to activate
    Select(name) {
        if (name = this.active)
            return

        if !this.registry.Has(name)
            throw Error("Unknown mode: " name)

        ; Disable the previous mode
        try {
            if this.registry.Has(this.active)
                this.registry[this.active].Disable()
        } catch {
            ; Ignore disable errors
        }

        ; Enable the new mode
        try {
            this.registry[name].Enable()
        } catch {
            ; Ignore enable errors
        }

        this.active := name
    }

}
