﻿<#
MIT License

Copyright (C) 2023 Robin Stolpe. 
robin@stolpe.io
<https://stolpe.io>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>
Function Update-RSWinSoftware {
    [CmdletBinding(SupportsShouldProcess)]
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
}
Function Confirm-RSWinGet {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "The GitHub API url for the latest release of WinGet")]
        [string]$GitHubUrl,
        [Parameter(Mandatory = $true, HelpMessage = "The headers and API version for the GitHub API")]
        [hashtable]$GithubHeaders,
        [Parameter(Mandatory = $true, HelpMessage = "Information about the installed version of WinGet")]
        [string]$WinGet
    )

    if ($null -eq $WinGet) {
        Write-Output = "WinGet is not installed, downloading and installing WinGet..."
    }
    else {
        Write-Output = "Checking if it's any newer version of WinGet to download and install..."
    }

    # Collecting information from GitHub regarding latest version of WinGet
    try {
        # If the computer is running PowerShell 7 or higher, use HTTP/3.0 for the GitHub API in other cases use HTTP/2.0
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            [System.Object]$GithubInfoRestData = Invoke-RestMethod -Uri $GitHubUrl -Method Get -Headers $GithubHeaders -TimeoutSec 10 -HttpVersion 3.0 | Select-Object -Property assets, tag_name
        }
        else {
            [System.Object]$GithubInfoRestData = Invoke-RestMethod -Uri $GitHubUrl -Method Get -Headers $GithubHeaders -TimeoutSec 10 | Select-Object -Property assets, tag_name
        }

        [string]$latestVersion = $GithubInfoRestData.tag_name.Substring(1)

        [System.Object]$GitHubInfo = [PSCustomObject]@{
            Tag         = $latestVersion
            DownloadUrl = $GithubInfoRestData.assets | where-object { $_.name -like "*.msixbundle" } | Select-Object -ExpandProperty browser_download_url
            OutFile     = "$env:TEMP\WinGet_$($latestVersion).msixbundle"
        }
    }
    catch {
        Write-Error @"
   "Message: "$($_.Exception.Message)`n
   "Error Line: "$($_.InvocationInfo.Line)`n
"@
        break
    }

    # Checking if the installed version of WinGet are the same as the latest version of WinGet
    if ($WinGet -le $GitHubInfo.Tag) {
        Write-Output "WinGet has a newer version $($GitHubInfo.Tag), downloading and installing it..."
        Invoke-WebRequest -UseBasicParsing -Uri $GitHubInfo.DownloadUrl -OutFile $GitHubInfo.OutFile

        Write-Output "Installing version $($GitHubInfo.Tag) of WinGet..."
        Add-AppxPackage $($GitHubInfo.OutFile)
    }
    else {
        Write-OutPut "Your already on the latest version of WinGet $($WinGet), no need to update."
    }
}
Function Get-RSInstallInfo {
    <## Checking what architecture your running
    # To Install visualcredist use vc_redist.x64.exe /install /quiet /norestart
    # Now we also need to verify that's the latest version and then download and install it if the latest version is not installed
    # When this is added no need to install Microsoft.VCLibs as it's included in the VisualCRedist
    # Don't have the time for it now but this will be added later#>


    # Getting architecture of the computer and adapting it after the right download links
    [string]$Architecture = $(Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty SystemType)
    switch ($Architecture) {
        "x64-based PC" {
            [string]$VisualCRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
            [string]$VCLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
            [string]$Arch = "x64"
        }
        "ARM64-based PC" {
            [string]$VisualCRedistUrl = "https://aka.ms/vs/17/release/vc_redist.arm64.exe"
            [string]$VCLibsUrl = "https://aka.ms/Microsoft.VCLibs.arm64.14.00.Desktop.appx"
            [string]$Arch = "arm64"
        }
        "x86-based PC" {
            [string]$VisualCRedistUrl = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
            [string]$VCLibsUrl = "https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx"
            [string]$Arch = "arm64"
        }
        default {
            Write-Error "Your running a unsupported architecture, exiting now..."
            break
        }
    }

    # Collects everything in pscustomobject to get easier access to the information
    [System.Object]$SysInfo = [PSCustomObject]@{
        VCLibs           = $(Get-AppxPackage -Name "Microsoft.VCLibs.140.00" -AllUsers | Where-Object { $_.Architecture -eq $Arch })
        WinGet           = $(try { (Get-AppxPackage -Name Microsoft.DesktopAppInstaller).version } catch { $Null })
        VisualCRedistUrl = $VisualCRedistUrl
        $VCLibsUrl       = $VCLibsUrl
        Arch             = $Arch
    }

    return $SysInfo
}
Function Install-RSVCLib {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "The path to the output file for the VCLibs when downloaded")]
        [string]$VCLibsOutFile,
        [Parameter(Mandatory = $true, HelpMessage = "Url path to where the VCLibs can be downloaded from")]
        [string]$VCLibsUrl
    )

    try {
        Write-Output "Microsoft.VCLibs is not installed, downloading and installing it now..."
        Invoke-WebRequest -UseBasicParsing -Uri $VCLibsUrl -OutFile $VCLibsOutFile

        Add-AppxPackage $VCLibsOutFile
    }
    catch {
        Write-Error "Something went wrong when trying to install Microsoft.VCLibs..."
        Write-Error @"
   "Message: "$($_.Exception.Message)`n
   "Error Line: "$($_.InvocationInfo.Line)`n
"@
        break
    }
}
Function Start-RSWinGet {
    [CmdletBinding(SupportsShouldProcess)]
    param( )
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