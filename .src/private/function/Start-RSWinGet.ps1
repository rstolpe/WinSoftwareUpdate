Function Start-RSWinGet {
    <#
        .SYNOPSIS
        This function is connected and used of the main function for this module, Update-RSWinSoftware.
        So when you run the Update-RSWinSoftware function this function will be called during the process.

        .DESCRIPTION
        This will start the WinGet.exe upgrade process.

        .LINK
        https://github.com/rstolpe/WinSoftwareUpdate/blob/main/README.md

        .NOTES
        Author:         Robin Stolpe
        Mail:           robin@stolpe.io
        Twitter:        https://twitter.com/rstolpes
        Linkedin:       https://www.linkedin.com/in/rstolpe/
        Website/Blog:   https://stolpe.io
        GitHub:         https://github.com/rstolpe
        PSGallery:      https://www.powershellgallery.com/profiles/rstolpe
    #>

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