Function Install-RSVCLibs {
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