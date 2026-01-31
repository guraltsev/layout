#Requires AutoHotkey v2.0

; LayoutManager - Dynamic hotkey management for keyboard layouts
;
; This class manages enabling/disabling layout-specific hotkeys dynamically,
; replacing the need for #HotIf blocks with conditional logic.
;
; Benefits:
;   - Clean enable/disable of layout hotkeys
;   - No "ghost" hotkeys after switching layouts
;   - Easy to add new layouts as data
;
; Usage:
;   layoutMgr := LayoutManager(layoutRegistry)
;   layoutMgr.Select("Colemak")

class LayoutManager {
    ; Constructor
    ; layoutRegistry - Map of layout name -> layout definition object
    ;   Each layout definition should have:
    ;     - name: Display name
    ;     - abbr: Abbreviation
    ;     - icon: Icon path (can be empty)
    ;     - remaps: Map of scancode -> output character
    ;     - accentMappers: Array of OneShotMapper instances for accent composition
    __New(layoutRegistry) {
        this.registry := layoutRegistry
        this.activeName := ""
        this.activeHotkeys := []  ; Store hotkey strings to disable later
        this.activeMappers := []  ; Store OneShotMapper instances
    }

    ; Select and activate a layout
    ; name - The layout name to activate
    Select(name) {
        if (name = this.activeName)
            return

        this.DisableActive()

        if !this.registry.Has(name) {
            ; If unknown layout, just clear and return
            return
        }

        def := this.registry[name]
        this.EnableLayout(def)
        this.activeName := name
    }

    ; Disable the currently active layout
    DisableActive() {
        ; Disable all registered hotkeys
        for hk in this.activeHotkeys {
            try Hotkey(hk, "Off")
            catch {
            }
        }
        this.activeHotkeys := []

        ; Disable all accent mappers
        for mapper in this.activeMappers {
            try mapper.Disable()
            catch {
            }
        }
        this.activeMappers := []

        this.activeName := ""
    }

    ; Enable a layout's hotkeys
    EnableLayout(def) {
        ; Register key remaps
        for sc, out in def.remaps {
            ; Use ObjBindMethod to capture 'out' value at creation time
            ; (closures in AHKv2 capture by reference, causing all to use last value)
            fn := ObjBindMethod(this, "SendRemap", out)
            ; Use * wildcard prefix to fire hotkey even with modifiers held
            ; This is essential for Shift+key to work correctly with {Blind}
            hk := "*" . sc
            try {
                Hotkey(hk, fn, "On")
                this.activeHotkeys.Push(hk)
            } catch {
            }
        }

        ; Enable accent mappers if defined
        if def.HasOwnProp("accentMappers") {
            for mapper in def.accentMappers {
                try {
                    mapper.Enable()
                    this.activeMappers.Push(mapper)
                } catch {
                }
            }
        }
    }

    ; Send remapped character
    SendRemap(val, *) {
        ; Use {Blind} to preserve modifier states (Shift, Ctrl, Alt, Win)
        ; This ensures Shift+key sends the shifted character (e.g., Shift+a -> A)
        ; Works for both literal characters and special keys like {Backspace}
        Send("{Blind}" . val)
    }

    ; Get the currently active layout name
    GetActive() {
        return this.activeName
    }
}
