function Get-Permutation {
    <#
        .SYNOPSIS
            Get k permutations of n.
        .DESCRIPTION
            Get k permutations of n.
        .EXAMPLE
            Get-Permutation 6 3
        .EXAMPLE
            Get-Permutation 6 3 -Method 'Factorial'
        .LINK
            http://en.wikipedia.org/wiki/Permutation
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-Factorial, Get-LogGamma
    #>
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateRange(0,[int]::MaxValue)]
        [int] $n,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateRange(0,[int]::MaxValue)]
        [int] $k,

        # Choose the method used to calculate permutations. Valid values are 'Factorial' and 'LogGamma'.
        # Default value is 'LogGamma'.
        [Parameter()]
        [ValidateSet('Factorial','LogGamma')]
        [string] $Method = 'LogGamma'
    )

    switch ($Method) {
        'Factorial' { (Get-Factorial $n) / (Get-Factorial ($n - $k)) }
        'LogGamma' { [math]::Round([math]::Exp((Get-LogGamma ($n + 1)) - (Get-LogGamma ($n - $k + 1)))) }
    }
}