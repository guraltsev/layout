#requires AutoHotkey v2
#SingleInstance Force

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

;;;;;;;;;;;;;;;;;;;;;;;;; LAYOUTS ;;;;;;;;;;;;;;;;;;;;;;;;;

;; Compose maps
global AcuteAccent := Map(
    "a", "á",  ; (á) a with acute
    "A", "Á",  ; (Á) A with acute
    "c", "ć",  ; (ć) c with acute
    "C", "Ć",  ; (Ć) C with acute
    "e", "é",  ; (é) e with acute
    "E", "É",  ; (É) E with acute
    "g", "ǵ",  ; (ǵ) g with acute
    "G", "Ǵ",  ; (Ǵ) G with acute
    "i", "í",  ; (í) i with acute
    "I", "Í",  ; (Í) I with acute
    "k", "ḱ",  ; (ḱ) k with acute
    "K", "Ḱ",  ; (Ḱ) K with acute
    "l", "ĺ",  ; (ĺ) l with acute
    "L", "Ĺ",  ; (Ĺ) L with acute
    "m", "ḿ",  ; (ḿ) m with acute
    "M", "Ḿ",  ; (Ḿ) M with acute
    "n", "ń",  ; (ń) n with acute
    "N", "Ń",  ; (Ń) N with acute
    "o", "ó",  ; (ó) o with acute
    "O", "Ó",  ; (Ó) O with acute
    "p", "ṕ",  ; (ṕ) p with acute
    "P", "Ṕ",  ; (Ṕ) P with acute
    "r", "ŕ",  ; (ŕ) r with acute
    "R", "Ŕ",  ; (Ŕ) R with acute
    "s", "ś",  ; (ś) s with acute
    "S", "Ś",  ; (Ś) S with acute
    "u", "ú",  ; (ú) u with acute
    "U", "Ú",  ; (Ú) U with acute
    "w", "ẃ",  ; (ẃ) w with acute
    "W", "Ẃ",  ; (Ẃ) W with acute
    "y", "ý",  ; (ý) y with acute
    "Y", "Ý",  ; (Ý) Y with acute
    "z", "ź",  ; (ź) z with acute
    "Z", "Ź"  ; (Ź) Z with acute
)
global GraveAccent := Map(
    "a", "à",  ; (à) a with grave
    "A", "À",  ; (À) A with grave
    "e", "è",  ; (è) e with grave
    "E", "È",  ; (È) E with grave
    "i", "ì",  ; (ì) i with grave
    "I", "Ì",  ; (Ì) I with grave
    "o", "ò",  ; (ò) o with grave
    "O", "Ò",  ; (Ò) O with grave
    "u", "ù",  ; (ù) u with grave
    "U", "Ù",  ; (Ù) U with grave
)
global Diaeresis := Map(
    "a", "ä",  ; (ä) a with dieresis
    "A", "Ä",  ; (Ä) A with dieresis
    "e", "ë",  ; (ë) e with dieresis
    "E", "Ë",  ; (Ë) E with dieresis
    "i", "ï",  ; (ï) i with dieresis
    "I", "Ï",  ; (Ï) I with dieresis
    "o", "ö",  ; (ö) o with dieresis
    "O", "Ö",  ; (Ö) O with dieresis
    "u", "ü",  ; (ü) u with dieresis
    "U", "Ü",  ; (Ü) U with dieresis
)

LaTeXMath := Map(
    "``", "``",
    "a", "\alpha",
    "b", "\beta",
    "d", "\delta",
    "D", "\Delta",
    "e", "\epsilon",
    "f", "\phi",
    "F", "\Phi",
    "g", "\gamma",
    "G", "\Gamma",
    "h", "\eta",
    "j", "\theta",
    "J", "\Theta",
    "k", "\kappa",
    "l", "\lambda",
    "L", "\Lambda",
    "m", "\mu",
    "n", "\nu",
    "N", "\nabla",
    "p", "\pi",
    "P", "\Pi",
    "q", "\chi",
    "Q", "\Chi",
    "r", "\rho",
    "s", "\sigma",
    "t", "\tau",
    "u", "\upsilon",
    "w", "\omega",
    "W", "\Omega",
    "x", "\xi",
    "X", "\Xi",
    "y", "\psi",
    "Y", "\Psi",
    "z", "\zeta",
    "i", "\in",
    "0", "\emptyset",
    "I", "\infty",
    "\", "\setminus",
    "+", "\cup",
    "-", "\cap",
    "<", "\langle",
    ">", "\rangle"
)

UnicodeMath := Map(
    "a", "α",
    "b", "β",
    "d", "δ",
    "D", "Δ",
    "e", "ε",
    "f", "φ",
    "F", "Φ",
    "g", "γ",
    "G", "Γ",
    "h", "η",
    "j", "θ",
    "J", "Θ",
    "k", "κ",
    "l", "λ",
    "L", "Λ",
    "m", "μ",
    "n", "ν",
    "N", "Ν",
    "p", "π",
    "P", "Π",
    "q", "ψ",
    "Q", "Ψ",
    "r", "ρ",
    "s", "σ",
    "t", "τ",
    "u", "υ",
    "w", "ω",
    "x", "ξ",
    "X", "Ξ",
    "y", "υ",
    "Y", "Υ",
    "z", "ζ",
    "i", "∈",
    "0", "∅",
    "I", "∞",
)

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

#HotIf LaTeXMathInput == True 
SC029:: LaTeXMath_HKF ;; TODO make the function LaTeXMath_HKF know what is its hotkey


Persistent(1)