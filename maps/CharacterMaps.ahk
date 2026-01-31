#Requires AutoHotkey v2.0

;;;;;;;;;;;;;;;;;;;;;;;;; LAYOUTS ;;;;;;;;;;;;;;;;;;;;;;;;;

;; Compose maps
global AcuteAccentMap := Map(
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
global GraveAccentMap := Map(
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
global DiaeresisMap := Map(
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
