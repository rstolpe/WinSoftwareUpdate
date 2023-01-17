﻿Function Get-RSInstallInfo {
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