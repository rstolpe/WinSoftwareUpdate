Function Update-RSWinSoftware {
    <#
        .SYNOPSIS
        This module let users auto update their installed software on Windows 10, 11 with WinGet.

        .DESCRIPTION
        The module will check if WinGet is installed and up to date, if not it will install WinGet or update it.
        It will also if Microsoft.VCLibs is installed and if not it will install it.
        Besides that the module will check what aritecture the computer is running and download the correct version of Microsoft.VCLibs etc.
        Then it will check if there is any software that needs to be updated and if so it will update them.

        .PARAMETER SkipVersionCheck
        You can decide if you want to skip the WinGet version check, default it set to false. If you use the switch -SkipVersionCheck it will skip to check the version of WinGet.

        .EXAMPLE
        Update-RSWinSoftware
        # This command will run the module and check if WinGet and VCLibs are up to date.

        .EXAMPLE
        Update-RSWinSoftware -SkipVersionCheck
        # This command will run the module without checking if WinGet and VCLibs are up to date.

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

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Decide if you want to skip the WinGet version check, default it set to false")]
        [switch]$SkipVersionCheck = $false
    )

    #Check if script was started as Administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Write-Error ("{0} needs admin privileges, exiting now...." -f $MyInvocation.MyCommand)
        break
    }

    # =================================
    #         Static Variables
    # =================================
    #
    # GitHub url for the latest release
    [string]$GitHubUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    #
    # The headers and API version for the GitHub API
    [hashtable]$GithubHeaders = @{
        "Accept"               = "application/vnd.github.v3+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }
    #
    #
    [string]$VCLibsOutFile = "$env:TEMP\Microsoft.VCLibs.140.00.$($Arch).appx"


    # Getting system information
    [System.Object]$SysInfo = Get-RSInstallInfo

    # If user has choosen to skip the WinGet version don't check, if WinGet is not installed this will install WinGet anyway.
    if ($SkipVersionCheck -eq $false -or $null -eq $SysInfo.WinGet) {
        Install-RSWinGet -GitHubUrl $GitHubUrl -GithubHeaders $GithubHeaders
    }

    # If VCLibs are not installed it will get installed
    if ($null -eq $SysInfo.VCLibs) {
        Install-RSVCLibs -VCLibsUrl $SysInfo.VCLibsUrl -VCLibsOutFile $VCLibsOutFile
    }

    # Starts to check for updates of the installed software
    Start-RSWinGet
}