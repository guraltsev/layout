; ==============================================================================
; ModeManager
; ------------------------------------------------------------------------------
; Responsibility:
;   Ensure exactly one input mode is active at a time (e.g., off/latex/unicode).
; ==============================================================================
class ModeManager {
    ; ----------------------------------------------------------------------------
    ; __New(modeRegistry)
    ; Purpose:
    ;   Create a manager with access to the mode registry.
    ; Arguments:
    ;   modeRegistry (Map) - Map of name -> mode definition.
    ; Returns:
    ;   ModeManager instance.
    ; ----------------------------------------------------------------------------
    __New(modeRegistry) {
        this.registry := modeRegistry
        this.active := "off"
    }

    ; ----------------------------------------------------------------------------
    ; Select(name)
    ; Purpose:
    ;   Switch to a new mode, disabling the previous mode.
    ; Arguments:
    ;   name (string) - Mode registry key to activate.
    ; Returns:
    ;   Nothing. Throws if the mode is not registered.
    ; ----------------------------------------------------------------------------
    Select(name) {
        if (name = this.active)
            return
        if !this.registry.Has(name)
            throw Error("Unknown mode: " name)

        try this.registry[this.active].Disable()
        try this.registry[name].Enable()
        this.active := name
    }
}
