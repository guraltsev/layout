class ModeManager {
    __New(modeRegistry) {
        this.registry := modeRegistry
        this.active := "off"
    }

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
