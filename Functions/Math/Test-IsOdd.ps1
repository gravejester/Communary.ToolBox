function Test-IsOdd {
    param([uint32]$Number)
    if (($Number % 2) -eq 0) {
        Write-Output $false
    }
    else {
        Write-Output $true
    }
}