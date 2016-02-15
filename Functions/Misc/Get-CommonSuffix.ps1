function Get-CommonSuffix {
    [CmdletBinding()]
    param( 
        [Parameter(Position = 0)]
        [string]$String1,
        
        [Parameter(Position = 1)]
        [string]$String2,
     
        # Maximum length of the returned suffix.   
        [Parameter()]
        [int]$MaxSuffixLength,

        # Makes matches case-sensitive. By default, matches are not case-sensitive.
        [Parameter()]
        [switch] $CaseSensitive
    )

    if (-not($CaseSensitive)) {
        $String1 = $String1.ToLowerInvariant()
        $String2 = $String2.ToLowerInvariant()
    }

    $shortestStringLength = [Math]::Min($String1.Length,$String2.Length)

    if (($shortestStringLength -lt $MaxSuffixLength) -or ($MaxSuffixLength -eq 0)) {
        $MaxSuffixLength = $shortestStringLength
    }

    $tmp = Get-CommonPrefix ($String1[-1..-($String1.Length)] -join '') ($String2[-1..-($String2.Length)] -join '') -MaxPrefixLength $MaxSuffixLength -CaseSensitive:$CaseSensitive
    Write-Output ($tmp[-1..-($tmp.Length)] -join '')
}