#Requires AutoHotkey v2.0
#Include Utils.ahk

class WindowData {
    hwnd := 0
    title := ""
    className := ""
    processName := ""
    workspaceIndex := -1
    isVisible := false

    __New(hwnd, workspaceIndex) {
        this.hwnd := hwnd
        this.workspaceIndex := workspaceIndex
        try {
            this.title := WinGetTitle("ahk_id " . hwnd)
            this.className := WinGetClass("ahk_id " . hwnd)
            this.processName := WinGetProcessName("ahk_id " . hwnd)
            this.isVisible := DllCall("IsWindowVisible", "Ptr", hwnd)
        } catch {
            ; Window might have been destroyed before we could read its properties
        }
    }
}

class WorkspaceState {
    index := 1
    windows := Map() ; Key: hwnd, Value: WindowData

    __New(index) {
        this.index := index
    }

    AddWindow(windowData) {
        this.windows[windowData.hwnd] := windowData
    }

    RemoveWindow(hwnd) {
        if this.windows.Has(hwnd) {
            this.windows.Delete(hwnd)
        }
    }
}

class ProjectState {
    workspaces := Map() ; Key: workspaceIndex (1-based), Value: WorkspaceState
    focusedWindow := 0
    currentWorkspace := 1

    __New() {
        ; Initialize workspaces
        Loop 20 { ; Arbitrary initial limit, can grow dynamically if needed
            this.workspaces[A_Index] := WorkspaceState(A_Index)
        }
    }

    EnsureWorkspace(index) {
        if !this.workspaces.Has(index) {
            this.workspaces[index] := WorkspaceState(index)
        }
    }

    AddWindow(hwnd, workspaceIndex) {
        this.EnsureWorkspace(workspaceIndex)
        winData := WindowData(hwnd, workspaceIndex)
        this.workspaces[workspaceIndex].AddWindow(winData)
        Utils.Log("State: Added window " . hwnd . " to workspace " . workspaceIndex)
    }

    RemoveWindow(hwnd) {
        for index, ws in this.workspaces {
            if ws.windows.Has(hwnd) {
                ws.RemoveWindow(hwnd)
                Utils.Log("State: Removed window " . hwnd . " from workspace " . index)
                return
            }
        }
    }

    UpdateWindowWorkspace(hwnd, newWorkspaceIndex) {
        winData := ""
        oldIndex := -1
        
        ; Find and remove from old workspace
        for index, ws in this.workspaces {
            if ws.windows.Has(hwnd) {
                winData := ws.windows[hwnd]
                ws.RemoveWindow(hwnd)
                oldIndex := index
                break
            }
        }

        if (winData != "") {
            winData.workspaceIndex := newWorkspaceIndex
            this.EnsureWorkspace(newWorkspaceIndex)
            this.workspaces[newWorkspaceIndex].AddWindow(winData)
            Utils.Log("State: Moved window " . hwnd . " from workspace " . oldIndex . " to " . newWorkspaceIndex)
        }
    }

    SetFocusedWindow(hwnd) {
        this.focusedWindow := hwnd
    }

    SetCurrentWorkspace(index) {
        this.currentWorkspace := index
    }
    
    GetWorkspaceForWindow(hwnd) {
        for index, ws in this.workspaces {
            if ws.windows.Has(hwnd) {
                return index
            }
        }
        return -1
    }
}
