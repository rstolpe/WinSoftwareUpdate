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