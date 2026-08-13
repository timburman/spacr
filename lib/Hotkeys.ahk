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
        prefix := ""
        if InStr(modStr, "alt")
            prefix .= "!"
        if InStr(modStr, "ctrl") || InStr(modStr, "control")
            prefix .= "^"
        if InStr(modStr, "shift")
            prefix .= "+"
        if InStr(modStr, "win") || InStr(modStr, "super") || InStr(modStr, "lwin") || InStr(modStr, "rwin")
            prefix .= "#"
        return (prefix != "") ? prefix : "!"
    }

    RegisterHotkeys() {
        modPrefix := this.GetModifierPrefix(this.config.modifier)
        moveModStr := this.config.modifier . "+" . this.config.moveModifier
        moveModPrefix := this.GetModifierPrefix(moveModStr)
        count := this.config.workspaceCount

        Utils.Log("Registering hotkeys for " . count . " workspaces with primary modifier '" . this.config.modifier . "' (" . modPrefix . ") and move modifier '" . this.config.moveModifier . "' (" . moveModPrefix . ")")

        Loop count {
            i := A_Index
            keyNum := (i == 10) ? "0" : String(i)

            ; Bind Switch Workspace: Primary Modifier + Number (e.g. Alt + 1..9)
            switchHotkey := modPrefix . keyNum
            try {
                Hotkey(switchHotkey, this.OnSwitchWorkspace.Bind(this, i))
            } catch as err {
                Utils.Log("Failed to bind switch hotkey " . switchHotkey . ": " . err.Message)
            }

            ; Bind Move Window: Primary + Move Modifier + Number (e.g. Alt + Shift + 1..9)
            moveHotkey := moveModPrefix . keyNum
            try {
                Hotkey(moveHotkey, this.OnMoveWindow.Bind(this, i))
            } catch as err {
                Utils.Log("Failed to bind move hotkey " . moveHotkey . ": " . err.Message)
            }
        }

        ; Bind Previous Workspace toggle: Primary Modifier + ` (grave accent)
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
