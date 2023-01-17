Function Start-RSWinGet {
    
    Write-OutPut "Checks if any softwares needs to be updated"
    try {
        WinGet.exe upgrade --all --silent --force --accept-source-agreements --disable-interactivity --include-unknown
        Write-Output "Everything is now completed, you can close this window"
    }
    catch {
        Write-Error @"
   "Message: "$($_.Exception.Message)`n
   "Error Line: "$($_.InvocationInfo.Line)`n
"@
    }
}