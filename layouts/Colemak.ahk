#Requires AutoHotkey v2.0

; Colemak Layout Definition
;
; This file defines the Colemak keyboard layout as data,
; making it easy to register and manage dynamically.
;
; Returns a layout definition object with:
;   - name: Display name
;   - abbr: Abbreviation for menu
;   - icon: Icon file path
;   - remaps: Map of scancode -> output character

ColemakLayoutDef() {
    ; Key remaps: scancode -> character
    ; Based on original layout.ahk Colemak block
    remaps := Map(
        ; Row 1 (QWERTY row)
        "SC010", "q",  ; q stays q
        "SC011", "w",  ; w stays w
        "SC012", "f",  ; e -> f
        "SC013", "p",  ; r -> p
        "SC014", "g",  ; t -> g
        "SC015", "j",  ; y -> j
        "SC016", "l",  ; u -> l
        "SC017", "u",  ; i -> u
        "SC018", "y",  ; o -> y
        "SC019", ";",  ; p -> ;

        ; Row 2 (Home row)
        "SC01E", "a",  ; a stays a
        "SC01F", "r",  ; s -> r
        "SC020", "s",  ; d -> s
        "SC021", "t",  ; f -> t
        "SC022", "d",  ; g -> d
        "SC023", "h",  ; h stays h
        "SC024", "n",  ; j -> n
        "SC025", "e",  ; k -> e
        "SC026", "i",  ; l -> i
        "SC027", "o",  ; ; -> o

        ; Row 3 (Bottom row)
        "SC02C", "z",  ; z stays z
        "SC02D", "x",  ; x stays x
        "SC02E", "c",  ; c stays c
        "SC02F", "v",  ; v stays v
        "SC030", "b",  ; b stays b
        "SC031", "k",  ; n -> k
        "SC032", "m",  ; m stays m

        ; Special keys
        "SC03A", "{Backspace}",  ; Capslock -> Backspace
        "SC00E", "{Backspace}"   ; Backspace stays Backspace
    )

    return {
        name: "Colemak",
        abbr: "Col",
        icon: "icons/col.ico",
        remaps: remaps
    }
}
