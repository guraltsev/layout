class LayoutManager {
    __New(layoutRegistry) {
        this.registry := layoutRegistry
        this.activeName := ""
        this.activeHotkeys := []
        this.activeDef := 0
    }

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

    SendRemap(val) {
        if RegExMatch(val, "^\{.+\}$")
            Send(val)
        else
            SendText(val)
    }
}
