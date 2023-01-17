
NAME
    Confirm-RSWinGet
    
SYNTAX
    Confirm-RSWinGet [-GitHubUrl] <string> [-GithubHeaders] <hashtable> [-WinGet] <string> [<CommonParameters>]
    
    
PARAMETERS
    -GitHubUrl <string>
        The GitHub API url for the latest release of WinGet
        
        Required?                    true
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -GithubHeaders <hashtable>
        The headers and API version for the GitHub API
        
        Required?                    true
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -WinGet <string>
        Information about the installed version of WinGet
        
        Required?                    true
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
    
INPUTS
    None
    
    
OUTPUTS
    System.Object
    
ALIASES
    None
    

REMARKS
    None


