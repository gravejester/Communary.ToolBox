function Get-StandardDeviation {
    <#
        .SYNOPSIS
            Get the standard variation of a set of numbers.
        .DESCRIPTION
            In statistics, the standard deviation is a measure that is used to quantify
            the amount of variation or dispersion of a set of data values. A standard deviation
            close to 0 indicates that the data points tend to be very close to the mean
            (also called the expected value) of the set, while a high standard deviation indicates
            that the data points are spread out over a wider range of values.
        .EXAMPLE
            Get-StandardDeviation -Set $mySet
        .LINK
            http://en.wikipedia.org/wiki/Standard_deviation
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 03.06.2015
            Version: 1.0
            Dependencies: Get-Variance
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [double[]] $Set,

        [Parameter()]
        [ValidateSet('Population','Sample')]
        [string] $Type = 'Population'
    )
    try {
        $variance = Get-Variance $Set -Type $Type
        Write-Output ([math]::Sqrt($variance))
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}