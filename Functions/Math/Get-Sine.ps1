function Get-Sine {
    param (
        [double] $Angle
    )
    Write-Output (([math]::Sin(($Angle | ConvertTo-Radians))))
}