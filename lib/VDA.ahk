#Requires AutoHotkey v2.0
#Include Utils.ahk

class VDA {
    dllPath := ""
    isInitialized := false

    __New(dllPath := "") {
        if (dllPath == "") {
            dllPath := A_ScriptDir "\dll\VirtualDesktopAccessor.dll"
        }
        this.dllPath := dllPath
        
        if !FileExist(this.dllPath) {
            Utils.Log("ERROR: VirtualDesktopAccessor.dll not found at: " . this.dllPath)
            this.isInitialized := false
            return
        }

        this.isInitialized := true
        Utils.Log("VDA initialized with DLL path: " . this.dllPath)
    }

    GetDesktopCount() {
        if !this.isInitialized {
            return -1
        }
        try {
            return DllCall(this.dllPath . "\GetDesktopCount", "Int")
        } catch as err {
            Utils.Log("VDA GetDesktopCount failed: " . err.Message)
            return -1
        }
    }

    CreateDesktop() {
        if !this.isInitialized {
            return false
        }
        try {
            DllCall(this.dllPath . "\CreateDesktop")
            return true
        } catch as err {
            Utils.Log("VDA CreateDesktop failed: " . err.Message)
            return false
        }
    }

    GoToDesktopNumber(zeroBasedIndex) {
        if !this.isInitialized {
            return false
        }
        try {
            DllCall(this.dllPath . "\GoToDesktopNumber", "Int", zeroBasedIndex)
            return true
        } catch as err {
            Utils.Log("VDA GoToDesktopNumber failed for index " . zeroBasedIndex . ": " . err.Message)
            return false
        }
    }

    MoveWindowToDesktopNumber(hwnd, zeroBasedIndex) {
        if !this.isInitialized || !hwnd {
            return false
        }
        try {
            DllCall(this.dllPath . "\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", zeroBasedIndex)
            return true
        } catch as err {
            Utils.Log("VDA MoveWindowToDesktopNumber failed for HWND " . hwnd . " and index " . zeroBasedIndex . ": " . err.Message)
            return false
        }
    }

    GetCurrentDesktopNumber() {
        if !this.isInitialized {
            return -1
        }
        try {
            return DllCall(this.dllPath . "\GetCurrentDesktopNumber", "Int")
        } catch as err {
            Utils.Log("VDA GetCurrentDesktopNumber failed: " . err.Message)
            return -1
        }
    }
}
