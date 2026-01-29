; ==============================================================================
; TrayUI
; ------------------------------------------------------------------------------
; Responsibility:
;   Build and render the system tray menu from registries and reflect state
;   selections (layout/mode/debug).
; ==============================================================================
class TrayUI {
    ; ----------------------------------------------------------------------------
    ; __New(registries, state, applyFn)
    ; Purpose:
    ;   Construct the tray UI helper bound to registries and state.
    ; Arguments:
    ;   registries (object) - { layouts: Map, modes: Map } registry object.
    ;   state (AppState)    - Application state instance.
    ;   applyFn (callable)  - Callback to apply state changes.
    ; Returns:
    ;   TrayUI instance.
    ; ----------------------------------------------------------------------------
    __New(registries, state, applyFn) {
        this.regs := registries
        this.state := state
        this.applyFn := applyFn

        this.layoutMenu := Menu()
        this.modeMenu := Menu()
        this.layoutCaptions := []
        this.modeCaptions := []
    }

    ; ----------------------------------------------------------------------------
    ; Build()
    ; Purpose:
    ;   Build the tray menu structure from registered layouts and modes.
    ; Arguments:
    ;   None.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    Build() {
        A_TrayMenu.Delete()

        for name, def in this.regs.layouts {
            this.layoutMenu.Add(def.name, ObjBindMethod(this, "SetLayout", name))
            this.layoutCaptions.Push(def.name)
            if (def.icon != "")
                this.layoutMenu.SetIcon(def.name, def.icon)
        }
        A_TrayMenu.Add("Layout", this.layoutMenu)

        for name, def in this.regs.modes {
            this.modeMenu.Add(def.name, ObjBindMethod(this, "SetMode", name))
            this.modeCaptions.Push(def.name)
        }
        A_TrayMenu.Add("Mode", this.modeMenu)

        A_TrayMenu.Add()
        A_TrayMenu.Add("Debug", ObjBindMethod(this, "ToggleDebug"))
        A_TrayMenu.Add("Reload", Reload)
        A_TrayMenu.Add("Exit", ExitApp)
    }

    ; ----------------------------------------------------------------------------
    ; Render(state)
    ; Purpose:
    ;   Update tray checks, icon, and tooltip to match the given state.
    ; Arguments:
    ;   state (AppState) - State to render.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    Render(state) {
        for caption in this.layoutCaptions {
            try this.layoutMenu.Uncheck(caption)
        }
        for caption in this.modeCaptions {
            try this.modeMenu.Uncheck(caption)
        }

        if this.regs.layouts.Has(state.layout) {
            cap := this.regs.layouts[state.layout].name
            try this.layoutMenu.Check(cap)
            icon := this.regs.layouts[state.layout].icon
            if (icon != "")
                TraySetIcon(icon)
        }

        if this.regs.modes.Has(state.mode) {
            cap := this.regs.modes[state.mode].name
            try this.modeMenu.Check(cap)
        }

        if state.debug
            A_TrayMenu.Check("Debug")
        else
            A_TrayMenu.Uncheck("Debug")

        A_IconTip := "Layout: " state.layout "`nMode: " state.mode
    }

    ; ----------------------------------------------------------------------------
    ; SetLayout(name)
    ; Purpose:
    ;   Update state to the selected layout and re-apply changes.
    ; Arguments:
    ;   name (string) - Layout registry key.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    SetLayout(name) {
        this.state.layout := name
        this.applyFn()
        this.state.Save()
        this.Render(this.state)
    }

    ; ----------------------------------------------------------------------------
    ; SetMode(name)
    ; Purpose:
    ;   Update state to the selected mode and re-apply changes.
    ; Arguments:
    ;   name (string) - Mode registry key.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    SetMode(name) {
        this.state.mode := name
        this.applyFn()
        this.state.Save()
        this.Render(this.state)
    }

    ; ----------------------------------------------------------------------------
    ; ToggleDebug()
    ; Purpose:
    ;   Toggle the debug flag and re-apply changes.
    ; Arguments:
    ;   None.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    ToggleDebug() {
        this.state.debug := !this.state.debug
        this.applyFn()
        this.state.Save()
        this.Render(this.state)
    }
}
