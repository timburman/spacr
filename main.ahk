#Requires AutoHotkey v2.0
#SingleInstance Force

#Include lib/Utils.ahk
#Include lib/Config.ahk
#Include lib/VDA.ahk
#Include lib/Events.ahk
#Include lib/State.ahk
#Include lib/WorkspaceManager.ahk
#Include lib/WindowTracker.ahk
#Include lib/Hotkeys.ahk

; Initialize Spacr Phase 2 Engine
cfg := Config()
vdaInst := VDA()

eventsBus := EventEmitter()
projState := ProjectState()
winTracker := WindowTracker(eventsBus, projState, vdaInst)

workspaceMgr := WorkspaceManager(vdaInst, cfg, eventsBus, projState)
hk := Hotkeys(workspaceMgr, cfg)

winTracker.Start()

OnExit((*) => winTracker.Stop())

Utils.Log("Spacr Phase 2 initialized and running.")
