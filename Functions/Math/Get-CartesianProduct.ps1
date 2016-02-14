function Get-CartesianProduct {
    <#
        .SYNOPSIS
            Get the Cartesian Product from two sets.
        .DESCRIPTION
            In mathematics, a Cartesian product is a mathematical operation which returns
            a set from multiple sets. That is, for sets A and B, the Cartesian product A × B
            is the set of all ordered pairs (a, b).
        .EXAMPLE
            Get-CartesianProduct (1,2,3) ('one','two','three')
        .LINK
            http://en.wikipedia.org/wiki/Cartesian_product
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 21.05.2015
            Version: 1.0
    #>
    [OutputType([System.Array])]
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [system.array] $Set1,

        [Parameter(Position = 1)]
        [system.array] $Set2,

        [Parameter()]
        [string] $Divider = ','
    )

    try {
        $outputArray = New-Object -TypeName System.Collections.ArrayList
        foreach ($set1Item in $Set1) {
            foreach ($set2Item in $Set2) {
                [void]$outputArray.Add(($set1Item.ToString() + $Divider + $set2Item.ToString()))
            }
        }
        Write-Output $outputArray
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}