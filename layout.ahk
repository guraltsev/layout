#Requires AutoHotkey v2.0
#SingleInstance Force

SendMode("Input")

#Include lib\AppState.ahk
#Include lib\OneShotMapper.ahk
#Include lib\LayoutManager.ahk
#Include lib\ModeManager.ahk
#Include lib\Registries.ahk
#Include lib\TrayUI.ahk

#Include CharacterMaps.ahk
#Include LaTeXMathInputMaps.ahk
#Include UnicodeMathInputMaps.ahk
#Include layouts\Colemak.ahk

state := AppState(A_ScriptDir "\config.ini")
state.Load()

registries := BuildRegistries()
layoutMgr := LayoutManager(registries.layouts)
modeMgr := ModeManager(registries.modes)

ApplyState := (*) => (
    layoutMgr.Select(state.layout),
    modeMgr.Select(state.mode)
)

tray := TrayUI(registries, state, ApplyState)
tray.Build()
ApplyState()
tray.Render(state)

return
