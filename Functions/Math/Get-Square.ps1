function Get-Square {
    param([double]$Number)
    $n = [math]::Abs($Number)
    Write-Output ($n * $n)
}