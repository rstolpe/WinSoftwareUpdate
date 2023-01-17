Function Update-RSWinSoftware {
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