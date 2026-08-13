#Requires AutoHotkey v2.0
#Include Utils.ahk

class Config {
    workspaceCount := 9
    modifier := "Alt"
    moveModifier := "Shift"
    followAfterMove := true

    __New(configFilePath := "") {
        if (configFilePath == "") {
            configFilePath := A_ScriptDir "\config.toml"
        }
        this.Load(configFilePath)
    }

    Load(filePath) {
        if !FileExist(filePath) {
            Utils.Log("Config file not found at: " . filePath . ". Using default configuration.")
            return
        }

        try {
            content := FileRead(filePath, "UTF-8")
        } catch as err {
            Utils.Log("Failed to read config file: " . err.Message)
            return
        }

        Loop Parse, content, "`n", "`r" {
            line := Trim(A_LoopField)
            
            ; Skip blank lines and full-line comments
            if (line == "" || SubStr(line, 1, 1) == "#" || SubStr(line, 1, 1) == "[") {
                continue
            }

            eqPos := InStr(line, "=")
            if (eqPos > 0) {
                key := Trim(SubStr(line, 1, eqPos - 1))
                valRaw := Trim(SubStr(line, eqPos + 1))
                parsedVal := Utils.ParseValue(valRaw)

                switch key {
                    case "workspace_count":
                        if IsNumber(parsedVal) && Integer(parsedVal) > 0 {
                            this.workspaceCount := Integer(parsedVal)
                        }
                    case "modifier":
                        this.modifier := String(parsedVal)
                    case "move_modifier":
                        this.moveModifier := String(parsedVal)
                    case "follow_after_move":
                        this.followAfterMove := !!parsedVal
                }
            }
        }

        ; Validate primary modifier to prevent standalone Shift from breaking standard symbol typing (!@#$%^&*())
        if (StrLower(Trim(this.modifier)) == "shift") {
            Utils.Log("WARNING: Standalone 'Shift' cannot be used as primary modifier. Defaulting primary modifier to 'Alt'.")
            this.modifier := "Alt"
        }

        Utils.Log("Config loaded successfully. workspace_count=" . this.workspaceCount . ", modifier=" . this.modifier . ", move_modifier=" . this.moveModifier . ", follow_after_move=" . (this.followAfterMove ? "true" : "false"))
    }
}
