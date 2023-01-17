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
        Website/Blog:   https://stolpe.io
        GitHub:         https://github.com/rstolpe
        PSGallery:      https://www.powershellgallery.com/profiles/rstolpe
    #>

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