#Requires AutoHotkey v2.0
#Include Utils.ahk
#Include Events.ahk
#Include State.ahk
#Include VDA.ahk

class WindowTracker {
    events := ""
    state := ""
    vda := ""
    
    ; WinEventHook handles
    hookCreateDestroy := 0
    hookForeground := 0
    hookLocation := 0

    ; Callback pointers
    cbWinEvent := 0

    __New(events, state, vda) {
        this.events := events
        this.state := state
        this.vda := vda
        this.cbWinEvent := CallbackCreate(ObjBindMethod(this, "HandleWinEvent"), "", 7)
    }

    Start() {
        this.EnumerateExistingWindows()
        this.RegisterHooks()
        Utils.Log("WindowTracker started.")
    }

    Stop() {
        if this.hookCreateDestroy
            DllCall("UnhookWinEvent", "Ptr", this.hookCreateDestroy)
        if this.hookForeground
            DllCall("UnhookWinEvent", "Ptr", this.hookForeground)
        if this.hookLocation
            DllCall("UnhookWinEvent", "Ptr", this.hookLocation)
            
        if this.cbWinEvent
            CallbackFree(this.cbWinEvent)
            
        Utils.Log("WindowTracker stopped.")
    }

    EnumerateExistingWindows() {
        windows := WinGetList()
        for hwnd in windows {
            if this.IsValidWindow(hwnd) {
                this.TrackWindow(hwnd)
            }
        }
    }

    TrackWindow(hwnd) {
        ; -1 or -2 might mean all desktops or unknown, but we get the index
        desktopIndex := this.vda.GetWindowDesktopNumber(hwnd)
        ; Since we use 1-based indexing for Spacr workspaces:
        workspaceIndex := desktopIndex + 1 
        
        if (workspaceIndex > 0) {
            this.state.AddWindow(hwnd, workspaceIndex)
            this.events.Emit("WindowCreated", hwnd)
        }
    }

    RegisterHooks() {
        ; EVENT_OBJECT_CREATE = 0x8000, EVENT_OBJECT_HIDE = 0x8003
        this.hookCreateDestroy := DllCall("SetWinEventHook"
            , "UInt", 0x8000, "UInt", 0x8003
            , "Ptr", 0
            , "Ptr", this.cbWinEvent
            , "UInt", 0, "UInt", 0, "UInt", 0)

        ; EVENT_SYSTEM_FOREGROUND = 0x0003
        this.hookForeground := DllCall("SetWinEventHook"
            , "UInt", 0x0003, "UInt", 0x0003
            , "Ptr", 0
            , "Ptr", this.cbWinEvent
            , "UInt", 0, "UInt", 0, "UInt", 0)
            
        ; EVENT_OBJECT_LOCATIONCHANGE = 0x800B
        this.hookLocation := DllCall("SetWinEventHook"
            , "UInt", 0x800B, "UInt", 0x800B
            , "Ptr", 0
            , "Ptr", this.cbWinEvent
            , "UInt", 0, "UInt", 0, "UInt", 0)
    }

    HandleWinEvent(hWinEventHook, event, hwnd, idObject, idChild, idEventThread, dwmsEventTime) {
        ; We only care about object-level events (OBJID_WINDOW = 0)
        if (idObject != 0) {
            return
        }

        if (event == 0x8000 || event == 0x8002) { ; EVENT_OBJECT_CREATE or EVENT_OBJECT_SHOW
            ; We don't check IsValidWindow here because IsWindowVisible might be false instantly upon creation.
            ; We delegate that check to the delayed timer.
            SetTimer(ObjBindMethod(this, "DelayedTrackWindow", hwnd), -50)
        }
        else if (event == 0x8001 || event == 0x8003) { ; EVENT_OBJECT_DESTROY or EVENT_OBJECT_HIDE
            if this.state.GetWorkspaceForWindow(hwnd) != -1 {
                this.state.RemoveWindow(hwnd)
                this.events.Emit("WindowDestroyed", hwnd)
            }
        }
        else if (event == 0x0003) { ; EVENT_SYSTEM_FOREGROUND
            if this.IsValidWindow(hwnd) {
                this.state.SetFocusedWindow(hwnd)
                this.events.Emit("ForegroundChanged", hwnd)
            }
        }
        else if (event == 0x800B) { ; EVENT_OBJECT_LOCATIONCHANGE
            ; For Phase 2, we just emit WindowMoved. Layout engine will handle resizing/moving logic later.
            if this.state.GetWorkspaceForWindow(hwnd) != -1 {
                this.events.Emit("WindowMoved", hwnd)
            }
        }
    }
    
    DelayedTrackWindow(hwnd) {
        if this.IsValidWindow(hwnd) && this.state.GetWorkspaceForWindow(hwnd) == -1 {
            this.TrackWindow(hwnd)
        }
    }

    IsValidWindow(hwnd) {
        if !hwnd || !DllCall("IsWindow", "Ptr", hwnd)
            return false
            
        ; Must be visible
        if !DllCall("IsWindowVisible", "Ptr", hwnd)
            return false

        try {
            exStyle := WinGetExStyle("ahk_id " . hwnd)
            if (exStyle & 0x00000080) ; WS_EX_TOOLWINDOW
                return false
                
            style := WinGetStyle("ahk_id " . hwnd)
            if (style & 0x40000000) ; WS_CHILD
                return false

            className := WinGetClass("ahk_id " . hwnd)
            title := WinGetTitle("ahk_id " . hwnd)
            
            ; Filter shell and system classes
            if (className == "Progman" || className == "WorkerW" || className == "Shell_TrayWnd")
                return false
                
            ; Filter UWP core windows that are not the actual app frame
            if (className == "Windows.UI.Core.CoreWindow")
                return false
                
            ; ApplicationFrameWindow is a host, sometimes empty if title is missing
            if (className == "ApplicationFrameWindow" && title == "")
                return false
                
            ; Tooltips and ghost windows
            if (className == "tooltips_class32" || className == "Ghost")
                return false
                
        } catch {
            return false
        }
            
        return true
    }
}
