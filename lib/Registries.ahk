SendMath(text) {
    SetKeyDelay(-1)
    SendEvent(text)
}

BuildRegistries() {
    regs := {}
    regs.layouts := Map()
    regs.modes := Map()

    regs.layouts["Colemak"] := ColemakLayoutDef()
    regs.layouts["None"] := {
        name: "None",
        abbr: "None",
        icon: "icons/default.ico",
        remaps: Map()
    }

    regs.modes["off"] := {
        name: "Off",
        abbr: "Off",
        Enable: (*) => 0,
        Disable: (*) => 0
    }

    latexMapper := OneShotMapper("SC029", LaTeXMathMap, SendMath)
    regs.modes["latex"] := {
        name: "LaTeX",
        abbr: "TeX",
        Enable: (*) => latexMapper.Enable(),
        Disable: (*) => latexMapper.Disable()
    }

    unicodeMapper := OneShotMapper("SC029", UnicodeMathMap, SendMath)
    regs.modes["unicode"] := {
        name: "Unicode",
        abbr: "Uni",
        Enable: (*) => unicodeMapper.Enable(),
        Disable: (*) => unicodeMapper.Disable()
    }

    return regs
}
