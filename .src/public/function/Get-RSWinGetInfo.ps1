Function Get-RSWinGetInfo {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Decide if you want to skip the WinGet version check, default it set to false")]
        [switch]$SkipVersionCheck = $false
    )
    
    # Checks if WinGet is installed and if it's installed it will collect the current installed version of WinGet
    [version]$CheckWinGet = $(try { (Get-AppxPackage -Name Microsoft.DesktopAppInstaller).version } catch { $Null })

}