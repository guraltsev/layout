# AHK Refactor — Scaffolding & Skeleton (Modules + APIs)

This file proposes a **directory layout**, **module responsibilities**, and **AHK v2 skeleton code** you can paste into files as a starting point.

The goal is not to be “done”; it’s to create the *shape* of the code so future features are plug-ins rather than edits across multiple globals/hotkey blocks.

---

## Recommended directory structure

```
ahk/
  main.ahk                       ; entry point (replaces layout.ahk)
  lib/
    AppState.ahk                 ; state + persistence
    TrayUI.ahk                   ; build menu + render checks/icons
    Registries.ahk               ; LayoutRegistry + ModeRegistry
    LayoutManager.ahk            ; enable/disable layout hotkeys
    ModeManager.ahk              ; enable/disable input modes (mappers)
    OneShotMapper.ahk            ; reusable capture-next-key mapper
    Util.ahk                     ; small helpers (optional)
  layouts/
    Colemak.ahk                  ; layout defs as data
  maps/
    CharacterMaps.ahk            ; moved from root, or keep as-is
    LaTeXMathInputMaps.ahk
    UnicodeMathInputMaps.ahk
```

You can keep your existing map files where they are; this structure is just clean.

---

## Module contracts (who owns what)

### AppState
- **Owns**: `layout`, `mode`, `debug`, `configPath`
- **Does not own**: tray menu objects, hotkeys, mapping logic
- **Provides**:
  - `Load()`, `Save()`

### Registries
- **Owns** the lists of:
  - layouts (name → layout def)
  - modes (name → mode def)
- **Does not own** state (state chooses which item is active)

### TrayUI
- **Owns** menu creation and rendering
- **Does not own** logic for enabling/disabling hotkeys
- Calls `applyFn(state)` after state changes

### LayoutManager
- **Owns** hotkeys created for the active layout
- Can disable/enable them cleanly without leaving “ghost” remaps

### ModeManager
- **Owns** enabling/disabling mapper instances for the active mode
- Enforces mutual exclusion (only one mode active)

### OneShotMapper
- **Owns**: trigger hotkey, input capture, map lookup, output sending
- Designed to be instantiated multiple times (accent compose, math modes, etc.)

---

## Skeleton: `main.ahk`

```ahk
#Requires AutoHotkey v2.0
#SingleInstance Force

#Include lib\AppState.ahk
#Include lib\Registries.ahk
#Include lib\LayoutManager.ahk
#Include lib\ModeManager.ahk
#Include lib\TrayUI.ahk
#Include lib\OneShotMapper.ahk

; --- Load maps (reuse your existing ones) ---
#Include maps\CharacterMaps.ahk
#Include maps\LaTeXMathInputMaps.ahk
#Include maps\UnicodeMathInputMaps.ahk
#Include layouts\Colemak.ahk

state := AppState(A_ScriptDir "\config.ini")
state.Load()

registries := BuildRegistries()   ; returns { layouts: Map(), modes: Map() }

layoutMgr := LayoutManager(registries.layouts)
modeMgr   := ModeManager(registries.modes)

ApplyState := (*) => (
    layoutMgr.Select(state.layout),
    modeMgr.Select(state.mode),
    TrayUI.Render(state)
)

TrayUI := TrayUI(registries, state, ApplyState)
TrayUI.Build()

; Apply once at startup
ApplyState()

return
```

---

## Skeleton: `lib/AppState.ahk`

```ahk
class AppState {
    __New(configPath) {
        this.configPath := configPath
        this.layout := "QWERTY"
        this.mode := "off"       ; "off" | "latex" | "unicode"
        this.debug := false
    }

    Load() {
        if !FileExist(this.configPath)
            return
        this.layout := IniRead(this.configPath, "State", "Layout", this.layout)
        this.mode   := IniRead(this.configPath, "State", "Mode", this.mode)
        this.debug  := IniRead(this.configPath, "State", "Debug", this.debug ? 1 : 0) = 1
    }

    Save() {
        IniWrite(this.layout, this.configPath, "State", "Layout")
        IniWrite(this.mode,   this.configPath, "State", "Mode")
        IniWrite(this.debug ? 1 : 0, this.configPath, "State", "Debug")
    }
}
```

---

## Skeleton: `lib/Registries.ahk`

This is where you register layouts and modes. Keep it declarative.

```ahk
BuildRegistries() {
    regs := {}
    regs.layouts := Map()
    regs.modes := Map()

    ; --- layouts ---
    ; QWERTY “layout” is a no-op layout (no remap hotkeys)
    regs.layouts["QWERTY"] := {
        name: "QWERTY",
        abbr: "QW",
        icon: "",
        remaps: Map()   ; no remaps
    }

    ; from layouts/Colemak.ahk
    regs.layouts["Colemak"] := ColemakLayoutDef()

    ; --- modes ---
    regs.modes["off"] := {
        name: "Off",
        abbr: "Off",
        Enable: (*) => 0,
        Disable: (*) => 0
    }

    ; LaTeX math mode (example trigger: SC029 = backtick)
    latexMapper := OneShotMapper("SC029", LaTeXMathMap, SendText)
    regs.modes["latex"] := {
        name: "LaTeX",
        abbr: "TeX",
        Enable: (*) => latexMapper.Enable(),
        Disable: (*) => latexMapper.Disable()
    }

    unicodeMapper := OneShotMapper("SC029", UnicodeMathMap, SendText)
    regs.modes["unicode"] := {
        name: "Unicode",
        abbr: "Uni",
        Enable: (*) => unicodeMapper.Enable(),
        Disable: (*) => unicodeMapper.Disable()
    }

    return regs
}
```

---

## Skeleton: `lib/LayoutManager.ahk`

```ahk
class LayoutManager {
    __New(layoutRegistry) {
        this.registry := layoutRegistry
        this.activeName := ""
        this.activeHotkeys := []  ; store key names to disable later
    }

    Select(name) {
        if (name = this.activeName)
            return

        this.DisableActive()

        if !this.registry.Has(name)
            throw Error("Unknown layout: " name)

        def := this.registry[name]
        this.EnableLayout(def)
        this.activeName := name
    }

    DisableActive() {
        for hk in this.activeHotkeys {
            try Hotkey(hk, "Off")
        }
        this.activeHotkeys := []
        this.activeName := ""
    }

    EnableLayout(def) {
        ; def.remaps: Map(scancode -> output)
        for sc, out in def.remaps {
            ; capture sc and out for closure:
            hk := sc
            val := out
            fn := (*) => this.SendRemap(val)
            Hotkey(hk, fn, "On")
            this.activeHotkeys.Push(hk)
        }
    }

    SendRemap(val) {
        ; Choose your preferred strategy:
        ; - If val is literal text: SendText(val)
        ; - If val is a key name: Send("{" val "}")
        SendText(val)
    }
}
```

---

## Skeleton: `lib/ModeManager.ahk`

```ahk
class ModeManager {
    __New(modeRegistry) {
        this.registry := modeRegistry
        this.active := "off"
    }

    Select(name) {
        if (name = this.active)
            return
        if !this.registry.Has(name)
            throw Error("Unknown mode: " name)

        ; Disable previous
        try this.registry[this.active].Disable()

        ; Enable new
        try this.registry[name].Enable()

        this.active := name
    }
}
```

---

## Skeleton: `lib/TrayUI.ahk`

Design: build menus once, callbacks update `state`, then call `applyFn()` and `state.Save()`.

```ahk
class TrayUI {
    __New(registries, state, applyFn) {
        this.regs := registries
        this.state := state
        this.applyFn := applyFn

        this.layoutMenu := Menu()
        this.modeMenu := Menu()
    }

    Build() {
        A_TrayMenu.Delete()

        ; Layout submenu (radio)
        for name, def in this.regs.layouts {
            this.layoutMenu.Add(def.name, (*) => this.SetLayout(name))
        }
        A_TrayMenu.Add("Layout", this.layoutMenu)

        ; Mode submenu (radio)
        for name, def in this.regs.modes {
            this.modeMenu.Add(def.name, (*) => this.SetMode(name))
        }
        A_TrayMenu.Add("Mode", this.modeMenu)

        A_TrayMenu.Add()
        A_TrayMenu.Add("Debug", (*) => this.ToggleDebug())
        A_TrayMenu.Add("Reload", (*) => Reload())
        A_TrayMenu.Add("Exit", (*) => ExitApp())

        this.Render(this.state)
    }

    Render(state) {
        ; Update checks. AHK v2 Menu.Check can check by item name (caption).
        ; So we must know captions; here we used def.name.
        try this.layoutMenu.UncheckAll()
        try this.modeMenu.UncheckAll()

        ; Check selected layout
        if this.regs.layouts.Has(state.layout) {
            cap := this.regs.layouts[state.layout].name
            try this.layoutMenu.Check(cap)
        }

        ; Check selected mode
        if this.regs.modes.Has(state.mode) {
            cap := this.regs.modes[state.mode].name
            try this.modeMenu.Check(cap)
        }

        ; Debug check
        if state.debug
            A_TrayMenu.Check("Debug")
        else
            A_TrayMenu.Uncheck("Debug")

        ; Optional: tooltip summary
        ToolTipText := "Layout: " state.layout "`nMode: " state.mode
        A_IconTip := ToolTipText
    }

    SetLayout(name) {
        this.state.layout := name
        this.state.Save()
        this.applyFn()
        this.Render(this.state)
    }

    SetMode(name) {
        this.state.mode := name
        this.state.Save()
        this.applyFn()
        this.Render(this.state)
    }

    ToggleDebug() {
        this.state.debug := !this.state.debug
        this.state.Save()
        this.applyFn()
        this.Render(this.state)
    }
}
```

> Note: `Menu.UncheckAll()` exists in v2, but if you run into compatibility issues, iterate items and uncheck explicitly. Keep this as a skeleton.

---

## Skeleton: `lib/OneShotMapper.ahk`

This encapsulates the pattern:
trigger → temporarily disable trigger → InputHook → map lookup → send.

```ahk
class OneShotMapper {
    __New(triggerHotkey, mapping, sendFn := SendText, captureLen := 1, timeoutMs := 0) {
        this.trigger := triggerHotkey
        this.map := mapping
        this.sendFn := sendFn
        this.captureLen := captureLen
        this.timeoutMs := timeoutMs
        this.enabled := false

        ; bind handler
        this._handler := ObjBindMethod(this, "OnTrigger")
    }

    Enable() {
        if this.enabled
            return
        Hotkey(this.trigger, this._handler, "On")
        this.enabled := true
    }

    Disable() {
        if !this.enabled
            return
        Hotkey(this.trigger, "Off")
        this.enabled := false
    }

    OnTrigger(*) {
        ; Disable the actual hotkey that fired
        hk := A_ThisHotkey
        try Hotkey(hk, "Off")

        ih := InputHook("L" this.captureLen)
        ih.VisibleNonText := true
        ih.KeyOpt("{All}", "E")  ; end on any key
        if (this.timeoutMs > 0)
            ih.Timeout := this.timeoutMs / 1000.0

        ih.Start()
        ih.Wait()

        key := ih.Input
        if (key = "") {
            ; nothing captured; re-enable and return
            try Hotkey(hk, "On")
            return
        }

        if this.map.Has(key) {
            out := this.map[key]
            this.sendFn(out)
        } else {
            ; fallback: send what was typed
            this.sendFn(key)
        }

        try Hotkey(hk, "On")
    }
}
```

**Notes**
- This keeps the implementation synchronous like your current code. If you later want non-blocking behavior, you can refactor `InputHook` usage to callbacks.
- For multi-character sequences, increase `captureLen` or switch to a “read until terminator” strategy.

---

## Skeleton: `layouts/Colemak.ahk`

```ahk
ColemakLayoutDef() {
    remaps := Map(
        "SC010", "q",
        "SC011", "w"
        ; ... fill out from your existing layout section
    )

    return {
        name: "Colemak",
        abbr: "CM",
        icon: "",       ; optional path
        remaps: remaps
    }
}
```

---

## Migration steps (practical)
1. Create the directory structure.
2. Copy your map files into `maps/` (or update the `#Include` paths).
3. Start with **Phase 1**: add `OneShotMapper`, convert one feature.
4. Move `layout.ahk` logic into `main.ahk` gradually.
5. Once stable, delete the old duplicated scripts (`LaTeXMathInput.ahk`, `UnicodeMathInput.ahk`) or keep them as “legacy”.

---

## What you get when this scaffolding is in place
- Adding a new mode becomes:
  1) add a map file
  2) register `OneShotMapper("SC029", NewMap, SendText)`
  3) add a mode registry entry
- Adding a new layout becomes:
  1) add `layouts/NewLayout.ahk` returning `{remaps: Map(...)}`
  2) register it in `BuildRegistries()`
- No more tray menu check logic scattered through feature code.
