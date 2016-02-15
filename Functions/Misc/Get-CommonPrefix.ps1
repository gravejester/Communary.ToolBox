function Get-CommonPrefix {
    [CmdletBinding()]
    param( 
        [Parameter(Position = 0)]
        [string]$String1,
        
        [Parameter(Position = 1)]
        [string]$String2,
     
        # Maximum length of the returned prefix.   
        [Parameter()]
        [int]$MaxPrefixLength,

        # Makes matches case-sensitive. By default, matches are not case-sensitive.
        [Parameter()]
        [switch] $CaseSensitive
    )

    if (-not($CaseSensitive)) {
        $String1 = $String1.ToLowerInvariant()
        $String2 = $String2.ToLowerInvariant()
    }

    $outputString = New-Object 'System.Text.StringBuilder'
    $shortestStringLength = [Math]::Min($String1.Length,$String2.Length)

    if (($shortestStringLength -lt $MaxPrefixLength) -or ($MaxPrefixLength -eq 0)) {
        $MaxPrefixLength = $shortestStringLength
    }

    for ($i = 0; $i -lt $MaxPrefixLength; $i++) {
        if ($String1[$i] -ceq $String2[$i]) {
            [void]$outputString.Append($String1[$i])
        }
        else { break }
    }

    Write-Output $outputString.ToString()
}