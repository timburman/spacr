#Requires AutoHotkey v2.0

class Utils {
    static Log(message) {
        OutputDebug("[Spacr] " . message . "`n")
    }

    static TrimQuotes(str) {
        str := Trim(str)
        if (SubStr(str, 1, 1) == '"' && SubStr(str, -1) == '"') || (SubStr(str, 1, 1) == "'" && SubStr(str, -1) == "'") {
            return SubStr(str, 2, StrLen(str) - 2)
        }
        return str
    }

    static ParseValue(valStr) {
        valStr := Trim(valStr)
        ; Remove trailing inline comments (# ...)
        if (InStr(valStr, " #")) {
            valStr := Trim(SubStr(valStr, 1, InStr(valStr, " #") - 1))
        }
        
        if (valStr = "true") {
            return true
        } else if (valStr = "false") {
            return false
        } else if IsNumber(valStr) {
            return Integer(valStr)
        } else {
            return Utils.TrimQuotes(valStr)
        }
    }
}
