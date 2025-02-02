#Requires AutoHotkey v2.0

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