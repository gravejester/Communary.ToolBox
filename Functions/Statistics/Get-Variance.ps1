function Get-Variance {
    <#
        .SYNOPSIS
            Get the variance of a set of numbers.
        .DESCRIPTION
            In probability theory and statistics, variance measures how far a set of numbers are spread out.
            A variance of zero indicates that all the values are identical. Variance is always non-negative: a small
            variance indicates that the data points tend to be very close to the mean (expected value) and hence to each other,
            while a high variance indicates that the data points are very spread out around the mean and from each other.
        .LINK
            http://en.wikipedia.org/wiki/Variance
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 03.06.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [double[]] $Set,

        # Choose the variance type; Population Variance or Sample Variance. Default value is 'Population'.
        [Parameter()]
        [ValidateSet('Population','Sample')]
        [string] $Type = 'Population'
    )

    [double]$mean = ($Set | Measure-Object -Average).Average

    foreach ($double in $Set) {
        $squaredDeviations += ,(($double - $mean) * ($double - $mean))
    }

    foreach ($squaredDeviation in $squaredDeviations) {
        $variance += $squaredDeviation
    }

    switch ($Type) {
        'Population' { $output = $variance / $Set.Count }
        'Sample' { $output = $variance / ($Set.Count - 1) }
    }

    Write-Output $output
}