class OneShotMapper {
    __New(triggerHotkey, mapping, sendFn := SendText, captureLen := 1, timeoutMs := 0) {
        this.trigger := triggerHotkey
        this.map := mapping
        this.sendFn := sendFn
        this.captureLen := captureLen
        this.timeoutMs := timeoutMs
        this.enabled := false
        this._handler := ObjBindMethod(this, "OnTrigger")
    }

    Enable() {
        if this.enabled
            return
        Hotkey(this.trigger, this._handler, "On")
        this.enabled := true
    }

    Disable() {
        if !this.enabled
            return
        Hotkey(this.trigger, "Off")
        this.enabled := false
    }

    OnTrigger(*) {
        hk := A_ThisHotkey
        try Hotkey(hk, "Off")

        ih := InputHook("L" this.captureLen)
        ih.VisibleNonText := true
        ih.KeyOpt("{All}", "E")
        if (this.timeoutMs > 0)
            ih.Timeout := this.timeoutMs / 1000.0

        ih.Start()
        ih.Wait()

        key := ih.Input
        if (key != "") {
            if this.map.Has(key) {
                this.sendFn(this.map[key])
            } else {
                this.sendFn(key)
            }
        }

        try Hotkey(hk, "On")
    }
}
