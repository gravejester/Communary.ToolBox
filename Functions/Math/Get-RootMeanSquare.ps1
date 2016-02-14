#https://en.wikipedia.org/wiki/Root_mean_square
function Get-RootMeanSquare {
    param ([double[]]$NumberSet)
    $squaredNumberSet = New-Object System.Collections.ArrayList
    foreach ($number in $NumberSet) {
        [void]$squaredNumberSet.Add((Get-Square $number))
    }
    Write-Output ([math]::Sqrt((($squaredNumberSet | Measure-Object -Average).Average)))
}