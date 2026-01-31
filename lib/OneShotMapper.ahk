#Requires AutoHotkey v2.0

; OneShotMapper - Reusable component for capture-next-key-and-map pattern
;
; This class encapsulates the common pattern of:
;   1. User presses trigger hotkey
;   2. Temporarily disable trigger to prevent recursion
;   3. Capture next key via InputHook
;   4. Look up captured key in mapping
;   5. Send mapped output (or fallback to original key)
;   6. Re-enable trigger hotkey
;
; Usage:
;   mapper := OneShotMapper("SC029", myMap, SendText)
;   mapper.Enable()   ; Start listening
;   mapper.Disable()  ; Stop listening

class OneShotMapper {
    ; Constructor
    ; triggerHotkey - The hotkey string that triggers this mapper (e.g., "SC029", ">!SC028")
    ; mapping       - A Map object containing key->output mappings
    ; sendFn        - Function to send the output (default: SendText)
    ; captureLen    - Number of characters to capture (default: 1)
    ; timeoutMs     - Timeout in milliseconds, 0 = no timeout (default: 0)
    __New(triggerHotkey, mapping, sendFn := unset, captureLen := 1, timeoutMs := 0) {
        this.trigger := triggerHotkey
        this.map := mapping
        this.sendFn := IsSet(sendFn) ? sendFn : SendText
        this.captureLen := captureLen
        this.timeoutMs := timeoutMs
        this.enabled := false

        ; Bind the handler method to this instance
        this._handler := ObjBindMethod(this, "OnTrigger")
    }

    ; Enable the mapper - starts listening for the trigger hotkey
    Enable() {
        if this.enabled
            return
        Hotkey(this.trigger, this._handler, "On")
        this.enabled := true
    }

    ; Disable the mapper - stops listening for the trigger hotkey
    Disable() {
        if !this.enabled
            return
        try Hotkey(this.trigger, "Off")
        this.enabled := false
    }

    ; Internal handler called when trigger hotkey is pressed
    OnTrigger(*) {
        ; Disable the trigger temporarily to prevent recursion
        hk := A_ThisHotkey
        try Hotkey(hk, "Off")

        ; Create InputHook to capture next key(s)
        ih := InputHook("L" this.captureLen)
        ih.VisibleNonText := true
        ih.KeyOpt("{All}", "E")  ; End on any key

        if (this.timeoutMs > 0)
            ih.Timeout := this.timeoutMs / 1000.0

        ih.Start()
        ih.Wait()

        key := ih.Input

        ; If nothing captured (e.g., timeout), re-enable and return
        if (key = "") {
            try Hotkey(hk, "On")
            return
        }

        ; Look up in map and send result
        if this.map.Has(key) {
            out := this.map[key]
            this.sendFn(out)
        } else {
            ; Fallback: send what was typed
            this.sendFn(key)
        }

        ; Re-enable the trigger hotkey
        try Hotkey(hk, "On")
    }
}
