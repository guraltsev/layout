class AppState {
    __New(configPath) {
        this.configPath := configPath
        this.layout := "Colemak"
        this.mode := "unicode"
        this.debug := false
    }

    Load() {
        if !FileExist(this.configPath)
            return
        this.layout := IniRead(this.configPath, "State", "Layout", this.layout)
        this.mode := IniRead(this.configPath, "State", "Mode", this.mode)
        this.debug := IniRead(this.configPath, "State", "Debug", this.debug ? 1 : 0) = 1
    }

    Save() {
        IniWrite(this.layout, this.configPath, "State", "Layout")
        IniWrite(this.mode, this.configPath, "State", "Mode")
        IniWrite(this.debug ? 1 : 0, this.configPath, "State", "Debug")
    }
}
