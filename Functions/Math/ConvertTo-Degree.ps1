function ConvertTo-Degree {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [double] $Radian
    )
    Write-Output ($Radian * (180 / [math]::PI))
}