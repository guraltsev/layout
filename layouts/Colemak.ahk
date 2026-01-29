; ==============================================================================
; Colemak Layout Definition
; ------------------------------------------------------------------------------
; Returns a layout object with remap definitions and compose extras.
; ==============================================================================
; ------------------------------------------------------------------------------
; ColemakLayoutDef()
; Purpose:
;   Build the Colemak layout definition used by the registry.
; Arguments:
;   None.
; Returns:
;   object - {
;     name, abbr, icon, remaps (Map), extras (array of OneShotMapper)
;   }
; ------------------------------------------------------------------------------
ColemakLayoutDef() {
    remaps := Map(
        "SC010", "q",
        "SC011", "w",
        "SC012", "f",
        "SC013", "p",
        "SC014", "g",
        "SC015", "j",
        "SC016", "l",
        "SC017", "u",
        "SC018", "y",
        "SC019", ";",
        "SC01E", "a",
        "SC01F", "r",
        "SC020", "s",
        "SC021", "t",
        "SC022", "d",
        "SC023", "h",
        "SC024", "n",
        "SC025", "e",
        "SC026", "i",
        "SC027", "o",
        "SC02C", "z",
        "SC02D", "x",
        "SC02E", "c",
        "SC02F", "v",
        "SC030", "b",
        "SC031", "k",
        "SC032", "m",
        "SC03A", "{Backspace}",
        "SC00E", "{Backspace}"
    )

    acuteMapper := OneShotMapper(">!SC028", AcuteAccentMap, SendText)
    graveMapper := OneShotMapper(">!SC029", GraveAccentMap, SendText)
    diaeresisMapper := OneShotMapper(">!SC019", DiaeresisMap, SendText)

    return {
        name: "Colemak",
        abbr: "Col",
        icon: "icons/col.ico",
        remaps: remaps,
        extras: [acuteMapper, graveMapper, diaeresisMapper]
    }
}
