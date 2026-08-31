#Requires AutoHotkey v2.0
#Include Utils.ahk
#Include VDA.ahk
#Include Config.ahk

class WorkspaceManager {
    vda := ""
    config := ""
    _currentWorkspace := 1
    _previousWorkspace := 1
    events := ""
    state := ""

    __New(vdaInstance, configInstance, eventsInstance := "", stateInstance := "") {
        this.vda := vdaInstance
        this.config := configInstance
        this.events := eventsInstance
        this.state := stateInstance
        
        ; Sync current workspace from VDA if available
        vdaCurrent := this.vda.GetCurrentDesktopNumber()
        if (vdaCurrent >= 0) {
            this._currentWorkspace := vdaCurrent + 1
            this._previousWorkspace := this._currentWorkspace
            if this.state {
                this.state.SetCurrentWorkspace(this._currentWorkspace)
            }
        }
        
        Utils.Log("WorkspaceManager initialized. Current workspace: " . this._currentWorkspace)
    }

    ; Ensures desktop 'n' exists, creating intermediate desktops if needed.
    EnsureDesktopExists(n) {
        if (n <= 0) {
            return false
        }

        count := this.vda.GetDesktopCount()
        if (count < 0) {
            Utils.Log("EnsureDesktopExists: Failed to query desktop count from VDA.")
            return false
        }

        while (count < n) {
            Utils.Log("Creating desktop " . (count + 1) . " to reach requested workspace " . n)
            if !this.vda.CreateDesktop() {
                Utils.Log("EnsureDesktopExists: Failed to create desktop.")
                return false
            }
            count := this.vda.GetDesktopCount()
        }
        return true
    }

    ; Centralized Explorer focus workaround to prevent flashing/taskbar glitches on desktop switch
    ApplyExplorerWorkaround() {
        try WinActivate("ahk_class Shell_TrayWnd")
        Sleep 20
    }

    ; Switch to workspace by 1-based index
    SwitchWorkspace(index) {
        if (index <= 0) {
            Utils.Log("SwitchWorkspace ignored: invalid index " . index)
            return false
        }

        ; Sync current workspace from VDA if possible
        vdaCurrent := this.vda.GetCurrentDesktopNumber()
        if (vdaCurrent >= 0) {
            actualCurrent := vdaCurrent + 1
            if (actualCurrent != this._currentWorkspace) {
                this._previousWorkspace := this._currentWorkspace
                this._currentWorkspace := actualCurrent
            }
        }

        ; Avoid redundant switch to current workspace
        if (index == this._currentWorkspace) {
            return true
        }

        if !this.EnsureDesktopExists(index) {
            Utils.Log("SwitchWorkspace failed: could not ensure existence of workspace " . index)
            return false
        }

        ; Centralized Explorer workaround before VDA switch
        this.ApplyExplorerWorkaround()

        zeroBasedIndex := index - 1
        success := this.vda.GoToDesktopNumber(zeroBasedIndex)

        if success {
            this._previousWorkspace := this._currentWorkspace
            this._currentWorkspace := index
            if this.state {
                this.state.SetCurrentWorkspace(index)
            }
            if this.events {
                this.events.Emit("WorkspaceChanged", index)
            }
            Utils.Log("Switched workspace: " . this._previousWorkspace . " -> " . this._currentWorkspace)
            Sleep 50
            return true
        } else {
            Utils.Log("SwitchWorkspace failed to switch to workspace " . index)
            return false
        }
    }

    ; Move target window to workspace index without switching current workspace
    MoveWindowToWorkspace(hwnd, index) {
        if (index <= 0) {
            Utils.Log("MoveWindowToWorkspace ignored: invalid index " . index)
            return false
        }

        if (!hwnd || hwnd == 0) {
            hwnd := WinExist("A")
        }

        if (!hwnd) {
            Utils.Log("MoveWindowToWorkspace ignored: no active or valid window handle")
            return false
        }

        if !this.EnsureDesktopExists(index) {
            Utils.Log("MoveWindowToWorkspace failed: could not ensure existence of workspace " . index)
            return false
        }

        zeroBasedIndex := index - 1
        success := this.vda.MoveWindowToDesktopNumber(hwnd, zeroBasedIndex)
        if success {
            Utils.Log("Moved HWND " . hwnd . " to workspace " . index)
            if this.state {
                this.state.UpdateWindowWorkspace(hwnd, index)
            }
            if this.events {
                this.events.Emit("WindowMoved", hwnd)
            }
            return true
        } else {
            Utils.Log("MoveWindowToWorkspace failed for HWND " . hwnd . " to workspace " . index)
            return false
        }
    }

    ; Move target window to workspace index and switch to that workspace
    MoveAndFollow(hwnd, index) {
        if (!hwnd || hwnd == 0) {
            hwnd := WinExist("A")
        }

        moved := this.MoveWindowToWorkspace(hwnd, index)
        if moved {
            switched := this.SwitchWorkspace(index)
            if (switched && hwnd) {
                try {
                    WinActivate("ahk_id " . hwnd)
                }
            }
            return switched
        }
        return false
    }

    ; Toggle to previous workspace
    PreviousWorkspace() {
        if (this._previousWorkspace <= 0 || this._previousWorkspace == this._currentWorkspace) {
            Utils.Log("PreviousWorkspace ignored: no valid distinct previous workspace (prev=" . this._previousWorkspace . ", current=" . this._currentWorkspace . ")")
            return false
        }
        target := this._previousWorkspace
        return this.SwitchWorkspace(target)
    }

    ; Returns 1-based current workspace index
    CurrentWorkspace() {
        vdaCurrent := this.vda.GetCurrentDesktopNumber()
        if (vdaCurrent >= 0) {
            this._currentWorkspace := vdaCurrent + 1
        }
        return this._currentWorkspace
    }

    ; Returns total number of virtual desktops
    WorkspaceCount() {
        count := this.vda.GetDesktopCount()
        return (count >= 0) ? count : 0
    }
}
