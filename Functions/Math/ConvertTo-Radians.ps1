function ConvertTo-Radian {
    <#
        .SYNOPSIS
            Convert from degrees to radian.
        .DESCRIPTION
            The radian is the standard unit of angular measure, used in many areas of mathematics.
            An angle's measurement in radians is numerically equal to the length of a corresponding
            arc of a unit circle; one radian is just under 57.3 degrees
            (when the arc length is equal to the radius).
        .LINK
            https://en.wikipedia.org/wiki/Radian
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Version: 1.0
    #>
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [double] $Degrees
    )
    Write-Output (([math]::PI * $Degrees) / 180.0)
}