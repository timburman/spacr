#Requires AutoHotkey v2.0
#SingleInstance Force

#Include lib/Utils.ahk
#Include lib/Config.ahk
#Include lib/VDA.ahk
#Include lib/WorkspaceManager.ahk
#Include lib/Hotkeys.ahk

; Initialize Spacr Phase 1 Engine
cfg := Config()
vdaInst := VDA()
workspaceMgr := WorkspaceManager(vdaInst, cfg)
hk := Hotkeys(workspaceMgr, cfg)

Utils.Log("Spacr Phase 1 Workspace Manager initialized and running.")
