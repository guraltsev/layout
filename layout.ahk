; This AutoHotkey v2 script creates a system tray-based keyboard layout switcher
; with accent character composition.

;; The keyboard layouts are defined in the CharacterMaps.ahk
;; The mathematical input maps are defined in the MathInputMaps.ahk


#requires AutoHotkey v2
#SingleInstance Force
#Include CharacterMaps.ahk
#Include MathInputMaps.ahk

KeyHistory(50) ; Used for debugging
; ListLines(1) ; Used for debugging
SendMode("Input")  ; optimizes for faster and more reliable input



Write_Output(message) {
    FileAppend(message . "`n", "*")
}



class Layout {
    __New(name, abrv, icon) {
        this.Name := name    ; Display name (e.g., "Colemak")
        this.Abrv := abrv    ; Abbreviation (e.g., "Col") for menu
        this.Icon := icon    ; Icon file path (e.g., "icons/col.ico")
    }
}

;; Define available layouts here
; Type: Array of Layout objects
; Description: Contains all available keyboard layouts with their display names, abbreviations, and icon paths
; Default Layouts:
;     Colemak: "Col", "icons/col.ico"
;     None: "None", "icons/default.ico"
global Layouts := [
    Layout("Colemak", "Col", "icons/col.ico"),
    Layout("None", "None", "icons/default.ico")
]

;; Initialize the layout index 
global LayoutIndex := 1 



;;;;;;;;;;;;;;;;;;;;;;;;; Helper functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;
_SwitchMenu() {
    global LayoutIndex
    ;; Clear all checks on enabled layouts
    For Index, Value in Layouts {
        A_TrayMenu.Uncheck(Layouts[Index].Abrv)
    }
    ;; Set the check on the current layout
    A_TrayMenu.Check(Layouts[LayoutIndex].Abrv)
}

_SwitchIcon() {
    global Layouts
    global LayoutIndex
    TraySetIcon(Layouts[LayoutIndex].Icon)
}

;;;;;;;;;;;;;;;;;;;;;; MENU ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; Radio buttons in menu ;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper function to handle radio selection
_Menu_SelectLayout(NewLayoutIndex, ItemName, ItemPos, MyMenu) {
    global LayoutIndex
    LayoutIndex:=NewLayoutIndex
    SwitchLayout()
}

;; Create radio buttons in Menu
 A_TrayMenu.Add("")
For Index, Value in Layouts {
    A_TrayMenu.Add(Layouts[Index].Abrv, _Menu_SelectLayout.Bind(Index),"Radio")
    A_TrayMenu.SetIcon(Layouts[Index].Abrv, Layouts[Index].Icon)

}
A_TrayMenu.Add("")

;;;;;;;;;;;;;;;;;;;;;; Layout Switching ;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
SwitchLayout()
RControl & RShift:: NextLayout


;; Configure the default composition 

;;;;;;;;;;;;;;;;;;;;;;; LaTeX Math Composition ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper function to toggle LaTeX Math Input
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

;;;;;;;;;;;;;;;;;;;;;;; Input processing ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This section handles the actual input processing 
IH := InputHook("L1") 
; InputHook is an AutoHotkey v2 class that creates a low-level 
; input monitoring mechanism. 
; The "L1" parameter specifies the input mode and length:
; "L1" means "Capture exactly one character of input and then stop"


;;;;;;;;;;;;;;;;;;;;;;;;; Layout Colemak ;;;;;;;;;;;;;;;;;;;;;;;;;

#HotIf Layouts[LayoutIndex].Name == "Colemak"
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
;; Use Right Alt + key to produce accented characters
RAlt_Quote_HKF() {
    IH.Start()
    IH.Wait()
    if (AcuteAccentMap.Has(IH.Input)) {
        Send AcuteAccentMap[IH.Input]
    }
}
>!SC028:: RAlt_Quote_HKF


RAlt_Backtick_HKF() {
    IH.Start()
    IH.Wait()
    if (GraveAccentMap.Has(IH.Input)) {
        Send GraveAccentMap[IH.Input]
    }
}
>!SC029:: RAlt_Backtick_HKF


RAlt_Quotationmarks_HKF() {
    IH.Start()
    IH.Wait()
    if (DiaeresisMap.Has(IH.Input)) {
        Send DiaeresisMap[IH.Input]
    }
}
>!SC019:: RAlt_Quotationmarks_HKF


;;;;;;;;;;;;;;;;;;;;;;;;; LaTeX Math Input using Backtick;;;;;;;;;;;;;;;;;;;;;;;;;
#HotIf LaTeXMathInput == True 

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
SC029:: LaTeXMath_HKF ;; TODO make the function LaTeXMath_HKF know what is its hotkey


Persistent(1)