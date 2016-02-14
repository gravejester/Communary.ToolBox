function Get-BinomialCoefficient {
    <#
        .SYNOPSIS
            Get the binomial coefficient between two positive integers.
        .DESCRIPTION
            In mathematics, binomial coefficients are a family of positive integers that occur as coefficients in the binomial theorem.
        .EXAMPLE
            Get-BinomialCoefficient 49 6
        .LINK
            http://en.wikipedia.org/wiki/Binomial_coefficient
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-Factorial, Get-LogGamma
    #>
    param (
        [ValidateRange(0,[int]::MaxValue)]
        [int] $n,

        [ValidateRange(0,[int]::MaxValue)]
        [int] $k,

        # Choose the method used to calculate the binomial coefficient.
        [ValidateSet('Factorial','LogGamma')]
        [string] $Method = 'LogGamma'
    )

    switch ($Method) {
        'Factorial' { (Get-Factorial $n) / ((Get-Factorial $k) * (Get-Factorial ($n - $k))) }
        'LogGamma' { [math]::Round([math]::Exp((Get-LogGamma ($n + 1)) - (Get-LogGamma ($k + 1)) - (Get-LogGamma ($n - $k + 1)))) }
    }
}