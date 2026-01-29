class TrayUI {
    __New(registries, state, applyFn) {
        this.regs := registries
        this.state := state
        this.applyFn := applyFn

        this.layoutMenu := Menu()
        this.modeMenu := Menu()
        this.layoutCaptions := []
        this.modeCaptions := []
    }

    Build() {
        A_TrayMenu.Delete()

        for name, def in this.regs.layouts {
            this.layoutMenu.Add(def.name, (*) => this.SetLayout(name))
            this.layoutCaptions.Push(def.name)
            if (def.icon != "")
                this.layoutMenu.SetIcon(def.name, def.icon)
        }
        A_TrayMenu.Add("Layout", this.layoutMenu)

        for name, def in this.regs.modes {
            this.modeMenu.Add(def.name, (*) => this.SetMode(name))
            this.modeCaptions.Push(def.name)
        }
        A_TrayMenu.Add("Mode", this.modeMenu)

        A_TrayMenu.Add()
        A_TrayMenu.Add("Debug", (*) => this.ToggleDebug())
        A_TrayMenu.Add("Reload", (*) => Reload())
        A_TrayMenu.Add("Exit", (*) => ExitApp())
    }

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

    SetLayout(name) {
        this.state.layout := name
        this.applyFn()
        this.state.Save()
        this.Render(this.state)
    }

    SetMode(name) {
        this.state.mode := name
        this.applyFn()
        this.state.Save()
        this.Render(this.state)
    }

    ToggleDebug() {
        this.state.debug := !this.state.debug
        this.applyFn()
        this.state.Save()
        this.Render(this.state)
    }
}
