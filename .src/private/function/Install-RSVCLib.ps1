Function Install-RSVCLib {
    <#
        .SYNOPSIS
        This function is connected and used of the main function for this module, Update-RSWinSoftware.
        So when you run the Update-RSWinSoftware function this function will be called during the process.

        .DESCRIPTION
        This function will install VCLibs if it's not installed on the computer.

        .PARAMETER VCLibsOutFile
        The path to the output file for the VCLibs when downloaded, this is pasted from the main function for this module, Update-RSWinSoftware.

        .PARAMETER VCLibsUrl
        The url path to where the VCLibs can be downloaded from, this is pasted from the main function for this module, Update-RSWinSoftware.

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