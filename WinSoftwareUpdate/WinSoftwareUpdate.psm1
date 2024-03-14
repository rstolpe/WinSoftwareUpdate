﻿<#
MIT License

Copyright (C) 2024 Robin Stolpe.
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

# Verify what version of Microsoft.UI.Xaml is installed
# Check if it needs to be updated and if so download and install it also download it if it's not installed
#"https://api.github.com/repos/microsoft/microsoft-ui-xaml/releases"
#Filter out Microsoft.UI.Xaml
# Fitler out latest 
#Get versionnumber
# Download nuget package
# Change name to .zip
# Extract .appx
# Then run Add-AppxPackage -Path .\Microsoft.UI.Xaml.X.X.appx

Function Confirm-RSWinGet {
    <#
        .SYNOPSIS
        This function is connected and used of the main function for this module, Update-RSWinSoftware.
        So when you run the Update-RSWinSoftware function this function will be called during the process.

        .DESCRIPTION
        This function will connect to the GitHub API and check if there is a newer version of WinGet to download and install.

        .PARAMETER GitHubUrl
        Url to the GitHub API for the latest release of WinGet

        .PARAMETER GithubHeaders
        The headers and API version for the GitHub API, this is pasted from the main function for this module, Update-RSWinSoftware.
        This is pasted in from the main function for this module, Update-RSWinSoftware.

        .PARAMETER WinGet


        .LINK
        https://github.com/rstolpe/WinSoftwareUpdate/blob/main/README.md

        .NOTES
        Author:         Robin Stolpe
        Mail:           robin@stolpe.io
        Twitter:        https://twitter.com/rstolpes
        Linkedin:       https://www.linkedin.com/in/rstolpe/
        GitHub:         https://github.com/rstolpe
        PSGallery:      https://www.powershellgallery.com/profiles/rstolpe
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Information about the installed version of WinGet")]
        [PSCustomObject]$SysInfo
    )

    # =================================
    #         Static Variables
    # =================================
    #
    # GitHub url for the latest release of WinGet
    [string]$WinGetUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    #
    # The headers and API version for the GitHub API
    [hashtable]$GithubHeaders = @{
        "Accept"               = "application/vnd.github.v3+json"
        "X-GitHub-Api-Version" = "2022-11-28"
    }

    # Collecting information from GitHub regarding latest version of WinGet
    try {
        # If the computer is running PowerShell 7 or higher, use HTTP/3.0 for the GitHub API in other cases use HTTP/2.0
        [System.Object]$GithubInfoRestData = Invoke-RestMethod -Uri $WinGetUrl -Method Get -Headers $GithubHeaders -TimeoutSec 10 -HttpVersion $SysInfo.HTTPVersion | Select-Object -Property assets, tag_name

        [System.Object]$GitHubInfo = [PSCustomObject]@{
            Tag         = $($GithubInfoRestData.tag_name.Substring(1))
            DownloadUrl = $GithubInfoRestData.assets | where-object { $_.name -like "*.msixbundle" } | Select-Object -ExpandProperty browser_download_url
            OutFile     = "$env:TEMP\WinGet_$($GithubInfoRestData.tag_name.Substring(1)).msixbundle"
        }
    }
    catch {
        Write-Error "Message: $($_.Exception.Message)`nError Line: $($_.InvocationInfo.Line)`n"
        break
    }

    # Checking if the installed version of WinGet are the same as the latest version of WinGet
    [version]$vWinGet = [string]$SysInfo.WinGet
    [version]$vGitHub = [string]$GitHubInfo.Tag
    if ([Version]$vWinGet -lt [Version]$vGitHub) {
        Write-Output "WinGet has a newer version $($vGitHub), downloading and installing it..."
        Write-Verbose "Downloading WinGet..."
        Invoke-WebRequest -UseBasicParsing -Uri $GitHubInfo.DownloadUrl -OutFile $GitHubInfo.OutFile

        Write-Verbose "Installing version $($vGitHub) of WinGet..."
        Add-AppxPackage $($GitHubInfo.OutFile)
        Write-Verbose "Deleting WinGet downloaded installation file..."
        Remove-Item $($GitHubInfo.OutFile) -Force
    }
    else {
        Write-Verbose "Your already on the latest version of WinGet $($vWinGet), no need to update."
        Continue
    }
}
Function Get-rsSystemInfo {
    <#
        .SYNOPSIS
        This function is connected and used of the main function for this module, Update-RSWinSoftware.
        So when you run the Update-RSWinSoftware function this function will be called during the process.

        .DESCRIPTION
        This function will collect the following data from the computer and store it in a PSCustomObject to make it easier for the main function for this module, Update-RSWinSoftware, to use the data.

        .LINK
        https://github.com/rstolpe/WinSoftwareUpdate/blob/main/README.md

        .NOTES
        Author:         Robin Stolpe
        Mail:           robin@stolpe.io
        Twitter:        https://twitter.com/rstolpes
        Linkedin:       https://www.linkedin.com/in/rstolpe/
        GitHub:         https://github.com/rstolpe
        PSGallery:      https://www.powershellgallery.com/profiles/rstolpe
    #>

    # Getting architecture of the computer and adapting it after the right download links
    [string]$Architecture = $(Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty SystemType)
    
    [string]$Arch = Switch ($Architecture) {
        "x64-based PC" { "x64" }
        "ARM64-based PC" { "arm64" }
        "x86-based PC" { "x86" }
        default { "Unsupported" }
    }

    if ($Arch -eq "Unsupported") {
        throw "Your running a unsupported architecture, exiting now..."
        break
    }
    else {

        # Verify verifying what ps version that's running and checks if pwsh7 is installed
        if ($PSVersionTable.PSVersion.Major -lt 7) {
            $VerifyPWSHInstallPath = Test-Path -Path "C:\Program Files\PowerShell\7\pwsh.exe"

            if ($VerifyPWSHInstallPath -eq $true) {
                [version]$CurrentPSVersion = (Get-Command "C:\Program Files\PowerShell\7\pwsh.exe").Version
            }
            else {
                [version]$CurrentPSVersion = $PSVersionTable.PSVersion
            }
        }
        else {
            [version]$CurrentPSVersion = $PSVersionTable.PSVersion
        }

        # Collects everything in pscustomobject to get easier access to the information
        # Need to redothis to hashtable
        [System.Object]$SysInfo = [PSCustomObject]@{
            VersionVClibs        = $(try { (Get-AppxPackage -AllUsers | Where-Object { $_.Architecture -eq $Arch -and $_.PackageFamilyName -like "Microsoft.VCLibs.140.00_8wekyb3d8bbwe" } | Sort-Object { $_.Version -as [version] } -Descending | Select-Object Version -First 1).version } catch { "0.0.0.0" })
            UrlVClibs            = "https://aka.ms/Microsoft.VCLibs.$($Arch).14.00.Desktop.appx"
            VersionMicrosoftXaml = $(try { (Get-AppxPackage -AllUsers | Where-Object { $_.Architecture -eq $Arch -and $_.PackageFamilyName -like "Microsoft.UI.Xaml.2.8_8wekyb3d8bbwe" } | Sort-Object { $_.Version -as [version] } -Descending | Select-Object Version -First 1).version } catch { "0.0.0.0" })
            UrlMicrosoftXaml     = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.$($Arch).appx"
            VersionVisualCRedist = ""
            UrlVisualCRedist     = "https://aka.ms/vs/17/release/vc_redist.$($Arch).exe"
            VersionWinGet        = $(try { (Get-AppxPackage -AllUsers | Where-Object { $_.Architecture -eq $Arch -and $_.PackageFamilyName -like "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" } | Sort-Object { $_.Version -as [version] } -Descending | Select-Object Version -First 1).version } catch { "0.0.0.0" })
            Arch                 = $Arch
            VersionPS            = [version]$CurrentPSVersion
            Temp                 = $env:TEMP
            HTTPVersion          = Switch ($PSVersionTable.PSVersion.Major) {
                7 { "3.0" }
                default { "2.0" }
            }
        }
        return $SysInfo
    }
}
Function Confirm-rsPowerShell7 {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER SID
        .PARAMETER Trim
        .EXAMPLE
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = ".")]
        [PSCustomObject]$SysInfo
    )
    # =================================
    #         Static Variables
    # =================================
    #
    # URL to the PowerShell GitHub raw content
    [string]$pwshurl = "https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json"

    $GetMetaData = Invoke-RestMethod -Uri $pwshurl -HttpVersion $SysInfo.HTTPVersion
    [version]$Release = $GetMetaData.StableReleaseTag -replace '^v'
    $PackageName = "PowerShell-${Release}-win-x64.msi"
    $PackagePath = Join-Path -Path $env:TEMP -ChildPath $PackageName
    $downloadURL = "https://github.com/PowerShell/PowerShell/releases/download/v${Release}/${PackageName}"

    # Check if powershell needs to update or not
    if ($SysInfo.VersionPS -lt $Release) {

        # Download latest MSI installer for PowerShell
        Invoke-RestMethod -Uri $downloadURL -OutFile $PackagePath

        # Setting arguments for the installation
        $ArgumentList = @("/i", $packagePath, "/quiet")

        $InstallProcess = Start-Process msiexec -ArgumentList $ArgumentList -Wait -PassThru
        if ($InstallProcess.exitcode -ne 0) {
            throw "Quiet install failed, please ensure you have administrator rights"
        }
        else {
            Write-Output "PowerShell 7 have been updated from $($SysInfo.VersionPS) to $($Release), you need to restart PowerShell to use the new version"
        }

        # Removes the installation file
        Remove-Item -Path $PackagePath -Force -ErrorAction SilentlyContinue
    }
}
Function Confirm-RSDependency {
    # Collecting systeminformation
    [System.Object]$SysInfo = Get-RSSystemInfo

    # If VCLibs are not installed it will get installed
    if ($null -eq $SysInfo.VersionVClibs -or $SysInfo.VersionVClibs -eq "0.0.0.0") {
        try {
            Write-Output "Microsoft.VCLibs is not installed, downloading and installing it now..."
            [string]$VCLibsOutFile = Join-Path -Path $SysInfo.Temp -ChildPath "Microsoft.VCLibs.140.00.$($SysInfo.Arch).appx"
            Write-Verbose "Downloading Microsoft.VCLibs..."
            Invoke-RestMethod -Uri $SysInfo.UrlVCLibs -OutFile $VCLibsOutFile -HttpVersion $SysInfo.HTTPVersion

            Write-Verbose "Installing Microsoft.VCLibs..."
            Add-AppxPackage $VCLibsOutFile
            Write-Verbose "Deleting Microsoft.VCLibs downloaded installation file..."
            Remove-Item $VCLibsOutFile -Force
        }
        catch {
            Write-Error "Message: $($_.Exception.Message)`nError Line: $($_.InvocationInfo.Line)`n"
            break
        }
    }

    # If VCLibs are not installed it will get installed
    if ($null -eq $SysInfo.VersionMicrosoftXaml -or $SysInfo.VersionMicrosoftXaml -eq "0.0.0.0") {
        try {
            Write-Output "Microsoft.UI.Xaml is not installed, downloading and installing it now..."
            [string]$XamlOutFile = Join-Path -Path $SysInfo.Temp -ChildPath "Microsoft.UI.Xaml.2.8.$($SysInfo.Arch).appx"
            Invoke-RestMethod -Uri $SysInfo.UrlMicrosoftXaml -OutFile $XamlOutFile -HttpVersion $SysInfo.HTTPVersion

            Add-AppxPackage $XamlOutFile
            Remove-Item $XamlOutFile -Force
        }
        catch {
            Write-Error "Message: $($_.Exception.Message)`nError Line: $($_.InvocationInfo.Line)`n"
            break
        }
    }

    # Install Microsoft Desktop App Installer

    # Install VisualCRedist
    # To Install visualcredist use vc_redist.x64.exe /install /quiet /norestart

    # If PowerShell 7 is installed on the system then it will check if it's the latest version and if not it will update it
    [version]$pwsh7 = "7.0.0.0"
    if ($SysInfo.VersionPS -ge $pwsh7) {
        Confirm-rsPowerShell7 -SysInfo $SysInfo
    }
    
    # If WinGet is not installed it will be installed and if it's any updates it will be updated
    Confirm-RSWinGet -SysInfo $SysInfo
}
Function Update-RSWinSoftware {
    <#
        .SYNOPSIS
        This module let users auto update their installed software on Windows 10, 11 with WinGet.

        .DESCRIPTION
        The module will check if WinGet is installed and up to date, if not it will install WinGet or update it.
        It will also if Microsoft.VCLibs is installed and if not it will install it.
        Besides that the module will check what aritecture the computer is running and download the correct version of Microsoft.VCLibs etc.
        Then it will check if there is any software that needs to be updated and if so it will update them.

        .EXAMPLE
        Update-RSWinSoftware
        # This command will run the module and check if WinGet and VCLibs are up to date.

        .LINK
        https://github.com/rstolpe/WinSoftwareUpdate/blob/main/README.md

        .NOTES
        Author:         Robin Stolpe
        Mail:           robin@stolpe.io
        Website:        https://stolpe.io
        Twitter:        https://twitter.com/rstolpes
        Linkedin:       https://www.linkedin.com/in/rstolpe/
        GitHub:         https://github.com/rstolpe
        PSGallery:      https://www.powershellgallery.com/profiles/rstolpe
    #>

    #Check if script was started as Administrator
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Write-Error ("{0} needs admin privileges, exiting now...." -f $MyInvocation.MyCommand)
        break
    }

    # Importing appx with -usewindowspowershell if your using PowerShell 7 or higher
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Import-Module appx -usewindowspowershell
        Write-Output "This messages is expected if you are using PowerShell 7 or higher`n"
    }

    # Check if something needs to be installed or updated
    Confirm-RSDependency

    # Checking if it's any softwares to update and if so it will update them
    Write-Output "Making sure that WinGet has the latest source list..."
    WinGet.exe source update

    Write-OutPut "Checks if any softwares needs to be updated...`n"
    try {
        WinGet.exe upgrade --all --silent --accept-source-agreements --accept-package-agreements --include-unknown --uninstall-previous
        Write-Output "Everything is now completed, you can close this window"
    }
    catch {
        Write-Error "Message: $($_.Exception.Message)`nError Line: $($_.InvocationInfo.Line)`n"
    }

    Write-OutPut "`n=== \\\ Script Finished /// ===`n"
}