#Requires AutoHotkey v2.0
#Include Utils.ahk

class EventEmitter {
    handlers := Map()

    On(eventName, callback) {
        if !this.handlers.Has(eventName) {
            this.handlers[eventName] := []
        }
        this.handlers[eventName].Push(callback)
    }

    Emit(eventName, args*) {
        if this.handlers.Has(eventName) {
            for idx, callback in this.handlers[eventName] {
                try {
                    callback(args*)
                } catch as err {
                    Utils.Log("Error in event handler for " . eventName . ": " . err.Message)
                }
            }
        }
    }
}
