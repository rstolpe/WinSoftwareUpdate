
NAME
    Confirm-RSWinGet
    
SYNOPSIS
    This function is connected and used of the main function for this module, Update-RSWinSoftware.
    So when you run the Update-RSWinSoftware function this function will be called during the process.
    
    
SYNTAX
    Confirm-RSWinGet [-GitHubUrl] <String> [-GithubHeaders] <Hashtable> [-WinGet] <String> [<CommonParameters>]
    
    
DESCRIPTION
    This function will connect to the GitHub API and check if there is a newer version of WinGet to download and install.
    

PARAMETERS
    -GitHubUrl <String>
        Url to the GitHub API for the latest release of WinGet
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -GithubHeaders <Hashtable>
        The headers and API version for the GitHub API, this is pasted from the main function for this module, Update-RSWinSoftware.
        This is pasted in from the main function for this module, Update-RSWinSoftware.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -WinGet <String>
        
        Required?                    true
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
NOTES
    
    
        Author:         Robin Stolpe
        Mail:           robin@stolpe.io
        Twitter:        https://twitter.com/rstolpes
        Linkedin:       https://www.linkedin.com/in/rstolpe/
        Website/Blog:   https://stolpe.io
        GitHub:         https://github.com/rstolpe
        PSGallery:      https://www.powershellgallery.com/profiles/rstolpe
    
    
RELATED LINKS
    https://github.com/rstolpe/WinSoftwareUpdate/blob/main/README.md


