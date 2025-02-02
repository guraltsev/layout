#requires AutoHotkey v2
#SingleInstance Force
#Include CharacterMaps.ahk

;InstallKeybdHook
KeyHistory(50)     ;; disables the key history (for privacy and security)
;ListLines(False)   ;; omits recently executed lines from history (for privacy and security)

SendMode("Input")  ; optimizes for faster and more reliable input

Write_Output(message) {
    FileAppend(message . "`n", "*")
}



global Layouts := ["Colemak", "None"]
global Layouts_Abrv := ["Col", "None"]
global LayoutIcon := ["icons/col.ico", "icons/default.ico"]



;;;;;;;;;;;;;;;;;;;;;;;;; Helper functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;
_SwitchMenu() {
    global Layouts
    global LayoutIndex
    global Layouts_Abrv
    For Index, Value in Layouts {
        A_TrayMenu.Uncheck(Layouts_Abrv[Index])
    }
    A_TrayMenu.Check(Layouts_Abrv[LayoutIndex])
}

_SwitchIcon() {
    global LayoutIndex
    global LayoutIcon
    TraySetIcon(LayoutIcon[LayoutIndex])
}

;;;;;;;;;;;;;;;;;;;;;; MENU ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; Radio buttons in menu ;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper function to handle radio selection
_Menu_SelectLayout(NewLayoutIndex, ItemName, ItemPos, MyMenu) {
    global LayoutIndex
    LayoutIndex:=NewLayoutIndex
    SwitchLayout()
}
; Create radio buttons in Menu
A_TrayMenu.Add("")
For Index, Value in Layouts {
    A_TrayMenu.Add(Layouts_Abrv[Index], _Menu_SelectLayout.Bind(Index),"Radio")
    A_TrayMenu.SetIcon(Layouts_Abrv[Index], LayoutIcon[Index])

}
A_TrayMenu.Add("")





;;; Switch layout function
;;; To use: set the global variable LayoutIndex and call SwitchLayout
SwitchLayout() {
    _SwitchMenu()
    _SwitchIcon()
}
;;; Switch to the next layout
NextLayout() {
    global LayoutIndex
    LayoutIndex := LayoutIndex + 1
    If (LayoutIndex > Layouts.Length) {
        LayoutIndex := 1
    }
    SwitchLayout()
}

;; Configure the default layout 
global LayoutIndex := 1
SwitchLayout()
RControl & RShift:: NextLayout
;; Configure the default composition 
global LaTeXMathInput := True
LaTeXMathInput_Toggle() {
    global LaTeXMathInput
    LaTeXMathInput := !LaTeXMathInput
}

A_TrayMenu.Add("")
A_TrayMenu.Add("LaTeXInput", _Menu_LaTeXMathInput)
if (LaTeXMathInput) {
    A_TrayMenu.Check("LaTeXInput")
} else {
    A_TrayMenu.Uncheck("LaTeXInput")
}

_Menu_LaTeXMathInput(ItemName, ItemPos, Menu) {
    global LaTeXMathInput
    LaTeXMathInput_Toggle()
    if (LaTeXMathInput) {
        A_TrayMenu.Check(ItemName)
    } else {
        A_TrayMenu.Uncheck(ItemName)
    }
}



IH := InputHook("L1")

RAlt_Quote_HKF() {
    IH.Start()
    IH.Wait()
    if (AcuteAccent.Has(IH.Input)) {
        Send AcuteAccent[IH.Input]
    }
}

RAlt_Backtick_HKF() {
    IH.Start()
    IH.Wait()
    if (GraveAccent.Has(IH.Input)) {
        Send GraveAccent[IH.Input]
    }
}
RAlt_Quotationmarks_HKF() {
    IH.Start()
    IH.Wait()
    if (Diaeresis.Has(IH.Input)) {
        Send Diaeresis[IH.Input]
    }
}

LaTeXMath_HKF() {
    Hotkey("SC029", "Off") ; SC029 is the scancode of the key "`"
    IH.Start()
    IH.Wait()

    ;; DEBUG
    ; Write_Output("LaTeXMath_HKF: " . IH.Input)

    if (LaTeXMath.Has(IH.Input)) {
        SetKeyDelay(-1)
        SendEvent LaTeXMath[IH.Input]
    }
    Hotkey("SC029", "On") ; SC029 is the scancode of the key "`"
}


;;;;;;;;;;;;;;;;;;;;;;;;; Layout Colemak ;;;;;;;;;;;;;;;;;;;;;;;;;

#HotIf Layouts[LayoutIndex] == "Colemak"
;; NumberRow
; SC029::` ;; Backtick
; SC02::1  ;; 1
; SC03::2  ;; 2
; SC04::3  ;; 3
; SC05::4  ;; 4
; SC06::5  ;; 5
; SC07::6  ;; 6
; SC08::7  ;; 7
; SC09::8  ;; 8
; SC0A::9  ;; 9
; SC0B::0  ;; 0
; SC0C::-  ;; -
; SC0D::=  ;; =


;; Row 1
SC010::q ;; q
SC011::w ;; w
SC012::f ;; e
SC013::p ;; r
SC014::g ;; t
SC015::j ;; y
SC016::l ;; u
SC017::u ;; i
SC018::y ;; o
SC019::; ;; p
; SC020::[ ;; [
; SC021::] ;; ]
; SC021::\ ;; \

;; Row 2
SC01E::a ;; a
SC01F::r ;; s
SC020::s ;; d
SC021::t ;; f
SC022::d ;; g
SC023::h ;; h
SC024::n ;; j
SC025::e ;; k
SC026::i ;; l
SC027::o ;; ;
; SC028::' ;; '

;; Row 2
SC02c::z ;; z
SC02d::x ;; x
SC02e::c ;; c
SC02f::v ;; v
SC030::b ;; b
SC031::k ;; n
SC032::m ;; m
; SC033::, ;; ,
; SC034::. ;; .
; SC034::/ ;; /

;; Other keys
SC03a::backspace ;; Capslock
SC00e::backspace ;; Backspace

;; Compose maps shortcuts
>!SC028:: RAlt_Quote_HKF
>!SC029:: RAlt_Backtick_HKF
>!SC019:: RAlt_Quotationmarks_HKF


;;;;;;;;;;;;;;;;;;;;;;;;; LaTeX Math Input using Backtick;;;;;;;;;;;;;;;;;;;;;;;;;
#HotIf LaTeXMathInput == True 
SC029:: LaTeXMath_HKF ;; TODO make the function LaTeXMath_HKF know what is its hotkey


Persistent(1)