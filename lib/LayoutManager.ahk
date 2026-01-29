; ==============================================================================
; LayoutManager
; ------------------------------------------------------------------------------
; Responsibility:
;   Enables and disables layout remap hotkeys for the active layout. Also manages
;   optional “extras” (e.g., compose mappers) that are tied to a layout.
; ==============================================================================
class LayoutManager {
    ; ----------------------------------------------------------------------------
    ; __New(layoutRegistry)
    ; Purpose:
    ;   Create a manager with access to a registry of layout definitions.
    ; Arguments:
    ;   layoutRegistry (Map) - Map of name -> layout definition.
    ; Returns:
    ;   LayoutManager instance.
    ; ----------------------------------------------------------------------------
    __New(layoutRegistry) {
        this.registry := layoutRegistry
        this.activeName := ""
        this.activeHotkeys := []
        this.activeDef := 0
    }

    ; ----------------------------------------------------------------------------
    ; Select(name)
    ; Purpose:
    ;   Activate the named layout, disabling the previous layout if needed.
    ; Arguments:
    ;   name (string) - Layout registry key to activate.
    ; Returns:
    ;   Nothing. Throws if the layout name is not registered.
    ; ----------------------------------------------------------------------------
    Select(name) {
        if (name = this.activeName)
            return

        this.DisableActive()

        if !this.registry.Has(name)
            throw Error("Unknown layout: " name)

        def := this.registry[name]
        this.EnableLayout(def)
        this.activeName := name
        this.activeDef := def
    }

    ; ----------------------------------------------------------------------------
    ; DisableActive()
    ; Purpose:
    ;   Disable all hotkeys and extras from the currently active layout.
    ; Arguments:
    ;   None.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    DisableActive() {
        for hk in this.activeHotkeys {
            try Hotkey(hk, "Off")
        }
        this.activeHotkeys := []

        if this.activeDef && this.activeDef.HasOwnProp("extras") {
            for mapper in this.activeDef.extras {
                mapper.Disable()
            }
        }

        this.activeName := ""
        this.activeDef := 0
    }

    ; ----------------------------------------------------------------------------
    ; EnableLayout(def)
    ; Purpose:
    ;   Enable all hotkeys for a layout definition and start any extras.
    ; Arguments:
    ;   def (object) - Layout definition { remaps: Map, extras?: [] }.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    EnableLayout(def) {
        for sc, out in def.remaps {
            hk := sc
            val := out
            fn := (*) => this.SendRemap(val)
            Hotkey(hk, fn, "On")
            this.activeHotkeys.Push(hk)
        }

        if def.HasOwnProp("extras") {
            for mapper in def.extras {
                mapper.Enable()
            }
        }
    }

    ; ----------------------------------------------------------------------------
    ; SendRemap(val)
    ; Purpose:
    ;   Send the remapped output for a layout key.
    ; Arguments:
    ;   val (string) - Output value; if formatted like "{Backspace}" it's sent
    ;                 as a key, otherwise sent as literal text.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    SendRemap(val) {
        if RegExMatch(val, "^\{.+\}$")
            Send(val)
        else
            SendText(val)
    }
}
