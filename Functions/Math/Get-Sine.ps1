function Get-Sine {
    # https://communary.wordpress.com/
    # https://github.com/gravejester/Communary.ToolBox
    param (
        [double] $Angle
    )
    Write-Output (([math]::Sin(($Angle | ConvertTo-Radians))))
}