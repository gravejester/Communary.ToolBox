function Get-Square {
    # https://communary.wordpress.com/
    # https://github.com/gravejester/Communary.ToolBox
    param([double]$Number)
    $n = [math]::Abs($Number)
    Write-Output ($n * $n)
}