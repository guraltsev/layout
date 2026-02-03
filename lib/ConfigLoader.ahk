#Requires AutoHotkey v2.0

; ConfigLoader - Runtime configuration loading from INI files
;
; This class loads layouts and character maps from INI files at runtime,
; allowing configuration changes without recompiling the script.
;
; File structure:
;   config/
;     layouts/
;       Colemak.ini      ; Layout definition with remaps
;       CustomLayout.ini ; User-defined layouts
;     maps/
;       acute.ini        ; Accent maps
;       grave.ini
;       diaeresis.ini
;       latex.ini        ; Math symbol maps
;       unicode.ini
;
; Layout INI format:
;   [Layout]
;   name=Colemak
;   abbr=Col
;   icon=icons/col.ico
;
;   [Remaps]
;   SC010=q
;   SC011=w
;   ...
;
; Map INI format:
;   [Map]
;   a=á
;   A=Á
;   ...
;
; Usage:
;   loader := ConfigLoader(A_ScriptDir "\config")
;   layouts := loader.LoadLayouts()
;   maps := loader.LoadMaps()

class ConfigLoader {
    ; Constructor
    ; configDir - Path to the config directory (contains layouts/ and maps/ subfolders)
    __New(configDir) {
        this.configDir := configDir
        this.layoutsDir := configDir "\layouts"
        this.mapsDir := configDir "\maps"
    }

    ; Load all layouts from config/layouts/*.ini
    ; Returns a Map of layout name -> layout definition object
    LoadLayouts() {
        layouts := Map()

        ; Check if layouts directory exists
        if !DirExist(this.layoutsDir) {
            return layouts
        }

        ; Find all INI files in layouts directory
        Loop Files, this.layoutsDir "\*.ini" {
            try {
                layoutDef := this.LoadLayoutFile(A_LoopFileFullPath)
                if (layoutDef && layoutDef.name != "") {
                    layouts[layoutDef.name] := layoutDef
                }
            } catch as err {
                ; Skip invalid layout files silently
            }
        }

        return layouts
    }

    ; Load a single layout from an INI file
    ; Returns a layout definition object
    LoadLayoutFile(filePath) {
        if !FileExist(filePath)
            return ""

        ; Read layout metadata
        name := IniRead(filePath, "Layout", "name", "")
        if (name = "")
            return ""

        abbr := IniRead(filePath, "Layout", "abbr", SubStr(name, 1, 3))
        icon := IniRead(filePath, "Layout", "icon", "")

        ; Read remaps
        remaps := Map()
        try {
            ; Read entire Remaps section
            remapSection := IniRead(filePath, "Remaps")
            if (remapSection != "") {
                ; Parse key=value pairs
                Loop Parse, remapSection, "`n", "`r" {
                    if (A_LoopField = "")
                        continue

                    ; Split on first =
                    eqPos := InStr(A_LoopField, "=")
                    if (eqPos > 0) {
                        key := Trim(SubStr(A_LoopField, 1, eqPos - 1))
                        value := Trim(SubStr(A_LoopField, eqPos + 1))
                        if (key != "" && value != "") {
                            remaps[key] := value
                        }
                    }
                }
            }
        } catch {
            ; Section might not exist
        }

        return {
            name: name,
            abbr: abbr,
            icon: icon,
            remaps: remaps
        }
    }

    ; Load a character map from an INI file
    ; Returns a Map of key -> value
    LoadMapFile(filePath) {
        mapping := Map()

        if !FileExist(filePath)
            return mapping

        try {
            fileText := FileRead(filePath, "UTF-8")
            inMapSection := false
            Loop Parse, fileText, "`n", "`r" {
                line := Trim(A_LoopField)
                if (line = "" || SubStr(line, 1, 1) = ";")
                    continue

                if (RegExMatch(line, "i)^\[(.+)\]$", &sectionMatch)) {
                    inMapSection := (StrLower(sectionMatch[1]) = "map")
                    continue
                }

                if (!inMapSection)
                    continue

                eqPos := InStr(line, "=")
                if (eqPos > 0) {
                    key := SubStr(line, 1, eqPos - 1)
                    value := SubStr(line, eqPos + 1)
                    ; Don't trim - preserve exact keys (spaces, special chars)
                    if (key != "") {
                        mapping[key] := value
                    }
                }
            }
        } catch {
            ; Section might not exist
        }

        return mapping
    }

    ; Load a named map from the maps directory
    ; mapName - Name of the map file (without .ini extension)
    LoadMap(mapName) {
        return this.LoadMapFile(this.mapsDir "\" mapName ".ini")
    }

    ; Load all maps from config/maps/*.ini
    ; Returns a Map of map name -> character map
    LoadAllMaps() {
        maps := Map()

        if !DirExist(this.mapsDir) {
            return maps
        }

        Loop Files, this.mapsDir "\*.ini" {
            try {
                ; Get map name from filename (without extension)
                SplitPath(A_LoopFileFullPath, , , , &nameNoExt)
                mapData := this.LoadMapFile(A_LoopFileFullPath)
                if (mapData.Count > 0) {
                    maps[nameNoExt] := mapData
                }
            } catch {
                ; Skip invalid files
            }
        }

        return maps
    }

    ; Check if config directory exists and has content
    HasConfig() {
        return DirExist(this.configDir)
    }

    ; Create default config directory structure
    CreateDefaultStructure() {
        if !DirExist(this.configDir)
            DirCreate(this.configDir)
        if !DirExist(this.layoutsDir)
            DirCreate(this.layoutsDir)
        if !DirExist(this.mapsDir)
            DirCreate(this.mapsDir)
    }
}
