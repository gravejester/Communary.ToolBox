function Test-IsFactorion {
    <#
        .SYNOPSIS
            Test if a number is a factorion.
        .DESCRIPTION
            Test if a number is a factorion.
        .EXAMPLE
            Test-IsFactorion 40585
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://en.wikipedia.org/wiki/Factorion
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
            Dependencies: ConvertTo-Digits, Get-Factorial
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateRange(1,[int]::MaxValue)]
        [int] $Number
    )

    [byte[]]$numberDigits = ConvertTo-Digits $Number
    $sum = 0
    foreach ($digit in ($numberDigits.GetEnumerator())) {
        $sum += Get-Factorial $digit
    }
    if ($sum -eq $Number) {
        Write-Output $true
    }
    else {
        Write-Output $false
    }
}