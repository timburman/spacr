#Requires AutoHotkey v2.0
#Include Utils.ahk
#Include WorkspaceManager.ahk
#Include Config.ahk

class Hotkeys {
    workspaceMgr := ""
    config := ""

    __New(workspaceMgrInstance, configInstance) {
        this.workspaceMgr := workspaceMgrInstance
        this.config := configInstance
        this.RegisterHotkeys()
    }

    GetModifierPrefix(modStr) {
        modStr := StrLower(Trim(modStr))
        switch modStr {
            case "alt":
                return "!"
            case "ctrl", "control":
                return "^"
            case "shift":
                return "+"
            case "win", "super", "lwin", "rwin":
                return "#"
            default:
                return "!"
        }
    }

    RegisterHotkeys() {
        modPrefix := this.GetModifierPrefix(this.config.modifier)
        shiftModPrefix := modPrefix . "+"
        count := this.config.workspaceCount

        Utils.Log("Registering hotkeys for " . count . " workspaces with modifier '" . this.config.modifier . "' (" . modPrefix . ")")

        Loop count {
            i := A_Index
            keyNum := (i == 10) ? "0" : String(i)

            ; Bind Switch Workspace: Modifier + Number (e.g. Alt + 1..9)
            switchHotkey := modPrefix . keyNum
            try {
                Hotkey(switchHotkey, this.OnSwitchWorkspace.Bind(this, i))
            } catch as err {
                Utils.Log("Failed to bind hotkey " . switchHotkey . ": " . err.Message)
            }

            ; Bind Move Window: Modifier + Shift + Number (e.g. Alt + Shift + 1..9)
            moveHotkey := shiftModPrefix . keyNum
            try {
                Hotkey(moveHotkey, this.OnMoveWindow.Bind(this, i))
            } catch as err {
                Utils.Log("Failed to bind hotkey " . moveHotkey . ": " . err.Message)
            }
        }

        ; Bind Previous Workspace toggle: Modifier + ` (grave accent)
        prevHotkey := modPrefix . "``"
        try {
            Hotkey(prevHotkey, (*) => this.workspaceMgr.PreviousWorkspace())
        } catch as err {
            Utils.Log("Failed to bind previous workspace hotkey " . prevHotkey . ": " . err.Message)
        }
    }

    OnSwitchWorkspace(index, *) {
        this.workspaceMgr.SwitchWorkspace(index)
    }

    OnMoveWindow(index, *) {
        hwnd := WinExist("A")
        if (this.config.followAfterMove) {
            this.workspaceMgr.MoveAndFollow(hwnd, index)
        } else {
            this.workspaceMgr.MoveWindowToWorkspace(hwnd, index)
        }
    }
}
