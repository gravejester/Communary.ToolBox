function Get-TrimmedMean {
    <#
        .SYNOPSIS
            Function to calculate the trimmed mean of a set of numbers.
        .DESCRIPTION
            Function to calculate the trimmed mean of a set of numbers.
            The default trim percent is 25, which when used will calculate the Interquartile Mean of the number set.
            Use the TrimPercent parameter to set the trim percent as needed.
        .EXAMPLE
            [double[]]$dataSet = 8, 3, 7, 1, 3, 9
            Get-TrimmedMean -NumberSet $dataSet
            Calculate the trimmed mean of the number set, using the default trim percent of 25.
        .NOTES
            Author: Øyvind Kallstad
            Date: 29.10.2014
            Version: 1.0
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [double[]] $NumberSet,

        # Trim percent. Default value is 25.
        [Parameter()]
        [ValidateRange(1,100)]
        [int] $TrimPercent = 25
    )

    try {
        # collect the number set into an arraylist and sort it
        $orderedSet = New-Object System.Collections.ArrayList
        $orderedSet.AddRange($NumberSet)
        $orderedSet.Sort()

        # calculate the trim count
        $numberSetLength = $orderedSet.Count
        $trimmedMean = $TrimPercent/100
        $trimmedCount = [Math]::Floor($trimmedMean * $numberSetLength)

        # subtract trim count from top and bottom of the number set
        [double[]]$trimmedSet = $orderedSet[$trimmedCount..($numberSetLength - ($trimmedCount+1))]

        # calculate the mean of the trimmed set
        Write-Output ($trimmedSet | Measure-Object -Average | Select-Object -ExpandProperty Average)
    }

    catch {
        Write-Warning $_.Exception.Message
    }
}