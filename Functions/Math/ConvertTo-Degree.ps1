function ConvertTo-Degree {
    # https://communary.wordpress.com/
    # https://github.com/gravejester/Communary.ToolBox
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [double] $Radian
    )
    Write-Output ($Radian * (180 / [math]::PI))
}