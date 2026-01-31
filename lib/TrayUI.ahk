#Requires AutoHotkey v2.0

; TrayUI - Data-driven tray menu management
;
; This class builds and renders the system tray menu from registries.
; It provides a clean separation between UI and logic.
;
; Features:
;   - Auto-generates menu items from layout/mode registries
;   - Updates check marks based on current state
;   - Routes callbacks to state updates via applyFn
;
; Usage:
;   trayUI := TrayUI(registries, state, applyFn)
;   trayUI.Build()

class TrayUI {
    ; Constructor
    ; registries - Object with .layouts and .modes Maps
    ; state      - AppState instance
    ; applyFn    - Callback function to apply state changes
    __New(registries, state, applyFn) {
        this.regs := registries
        this.state := state
        this.applyFn := applyFn

        this.layoutMenu := Menu()
        this.modeMenu := Menu()
    }

    ; Build the tray menu from registries
    Build() {
        A_TrayMenu.Delete()

        ; Layout submenu (radio buttons)
        for name, def in this.regs.layouts {
            ; Use ObjBindMethod to capture 'name' value at creation time
            ; (closures in AHKv2 capture by reference, causing all to use last value)
            callback := ObjBindMethod(this, "SetLayout", name)
            this.layoutMenu.Add(def.name, callback, "Radio")
            if (def.icon != "") {
                try this.layoutMenu.SetIcon(def.name, def.icon)
                catch {
                }
            }
        }
        A_TrayMenu.Add("Layout", this.layoutMenu)

        ; Mode submenu (radio buttons)
        for name, def in this.regs.modes {
            ; Use ObjBindMethod to capture 'name' value at creation time
            callback := ObjBindMethod(this, "SetMode", name)
            this.modeMenu.Add(def.name, callback, "Radio")
        }
        A_TrayMenu.Add("Mode", this.modeMenu)

        A_TrayMenu.Add()  ; Separator
        A_TrayMenu.Add("Debug", (*) => this.ToggleDebug())
        A_TrayMenu.Add()  ; Separator
        A_TrayMenu.Add("Reload", (*) => Reload())
        A_TrayMenu.Add("Exit", (*) => ExitApp())

        this.Render()
    }

    ; Render the current state to the menu (update checks, icon, tooltip)
    Render() {
        ; Uncheck all items in submenus
        this._UncheckAll(this.layoutMenu)
        this._UncheckAll(this.modeMenu)

        ; Check the selected layout
        if this.regs.layouts.Has(this.state.layout) {
            cap := this.regs.layouts[this.state.layout].name
            try this.layoutMenu.Check(cap)
            catch {
            }

            ; Update tray icon to match layout
            if (this.regs.layouts[this.state.layout].icon != "") {
                try TraySetIcon(this.regs.layouts[this.state.layout].icon)
                catch {
                }
            }
        }

        ; Check the selected mode
        if this.regs.modes.Has(this.state.mode) {
            cap := this.regs.modes[this.state.mode].name
            try this.modeMenu.Check(cap)
            catch {
            }
        }

        ; Debug check
        if this.state.debug {
            try A_TrayMenu.Check("Debug")
            catch {
            }
        } else {
            try A_TrayMenu.Uncheck("Debug")
            catch {
            }
        }

        ; Update tooltip
        A_IconTip := "Layout: " this.state.layout "`nMode: " this.state.mode
    }

    ; Set layout and apply
    SetLayout(name) {
        this.state.layout := name
        this.state.Save()
        this.applyFn()
        this.Render()
    }

    ; Set mode and apply
    SetMode(name) {
        this.state.mode := name
        this.state.Save()
        this.applyFn()
        this.Render()
    }

    ; Toggle debug mode
    ToggleDebug() {
        this.state.debug := !this.state.debug
        this.state.Save()
        this.applyFn()
        this.Render()
    }

    ; Helper to uncheck all items in a menu
    _UncheckAll(menu) {
        ; AHK v2 doesn't have UncheckAll, so we iterate through registry
        ; and uncheck each known item
        for name, def in this.regs.layouts {
            try menu.Uncheck(def.name)
            catch {
            }
        }
        for name, def in this.regs.modes {
            try menu.Uncheck(def.name)
            catch {
            }
        }
    }
}
