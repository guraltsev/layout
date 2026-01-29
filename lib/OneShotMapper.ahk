; ==============================================================================
; OneShotMapper
; ------------------------------------------------------------------------------
; Responsibility:
;   Encapsulates the repeated pattern of:
;     1) Trigger hotkey pressed
;     2) Capture next keystroke(s)
;     3) Map captured input to an output string
;     4) Send mapped output (or fallback to the raw input)
;   Used for one-shot input modes like LaTeX/Unicode math and compose accents.
; ==============================================================================
class OneShotMapper {
    ; ----------------------------------------------------------------------------
    ; __New(triggerHotkey, mapping, sendFn := SendText, captureLen := 1, timeoutMs := 0)
    ; Purpose:
    ;   Create a mapper for a specific trigger key and map.
    ; Arguments:
    ;   triggerHotkey (string) - Hotkey string (e.g., "SC029", ">!SC028").
    ;   mapping (Map)          - Map of captured input -> output string.
    ;   sendFn (callable)      - Function to send output (default: SendText).
    ;   captureLen (integer)   - Number of characters to capture (default: 1).
    ;   timeoutMs (integer)    - Optional timeout in ms (0 disables timeout).
    ; Returns:
    ;   OneShotMapper instance.
    ; ----------------------------------------------------------------------------
    __New(triggerHotkey, mapping, sendFn := SendText, captureLen := 1, timeoutMs := 0) {
        this.trigger := triggerHotkey
        this.map := mapping
        this.sendFn := sendFn
        this.captureLen := captureLen
        this.timeoutMs := timeoutMs
        this.enabled := false
        this._handler := ObjBindMethod(this, "OnTrigger")
    }

    ; ----------------------------------------------------------------------------
    ; Enable()
    ; Purpose:
    ;   Enable the trigger hotkey for this mapper.
    ; Arguments:
    ;   None.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    Enable() {
        if this.enabled
            return
        Hotkey(this.trigger, this._handler, "On")
        this.enabled := true
    }

    ; ----------------------------------------------------------------------------
    ; Disable()
    ; Purpose:
    ;   Disable the trigger hotkey for this mapper.
    ; Arguments:
    ;   None.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
    Disable() {
        if !this.enabled
            return
        Hotkey(this.trigger, "Off")
        this.enabled := false
    }

    ; ----------------------------------------------------------------------------
    ; OnTrigger(*)
    ; Purpose:
    ;   Hotkey handler: capture input, map it, and send output.
    ; Arguments:
    ;   * (ignored) - Hotkey callback signature compatibility.
    ; Returns:
    ;   Nothing.
    ; ----------------------------------------------------------------------------
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
