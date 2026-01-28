#Requires AutoHotkey v2.0

TraySetIcon("icons/UnicodeMathInput.ico") ;; Tray icon

#Include UnicodeMathInputMaps.ahk

;;;;;;;;;;;;;;;;;;;;;;; Input processing ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section handles the actual input processing
IH := InputHook("L1")
; InputHook is an AutoHotkey v2 class that creates a low-level
; input monitoring mechanism.
; The "L1" parameter specifies the input mode and length:
; "L1" means "Capture exactly one character of input and then stop"

;;;;;;;;;;;;;;;;;;;;;;;;; LaTeX Math Input using Backtick;;;;;;;;;;;;;;;;;;;;;;;;;
UnicodeMath_HKF() {
    Hotkey("SC029", "Off") ; SC029 is the scancode of the key "`"
    IH.Start()
    IH.Wait()

    ;; DEBUG
    ; Write_Output("LaTeXMath_HKF: " . IH.Input)

    if (UnicodeMathMap.Has(IH.Input)) {
        SetKeyDelay(-1)
        SendEvent UnicodeMathMap[IH.Input]
    }
    Hotkey("SC029", "On") ; SC029 is the scancode of the key "`"
}

; #HotIf LaTeXMathInput == True
SC029:: UnicodeMath_HKF ;; TODO make the function LaTeXMath_HKF know what is its hotkey
