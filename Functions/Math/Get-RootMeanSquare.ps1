# https://en.wikipedia.org/wiki/Root_mean_square
# https://communary.wordpress.com/
# https://github.com/gravejester/Communary.ToolBox
function Get-RootMeanSquare {
    param ([double[]]$NumberSet)
    $squaredNumberSet = New-Object System.Collections.ArrayList
    foreach ($number in $NumberSet) {
        [void]$squaredNumberSet.Add((Get-Square $number))
    }
    Write-Output ([math]::Sqrt((($squaredNumberSet | Measure-Object -Average).Average)))
}