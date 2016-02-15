function Test-IsEven {
    param([uint32]$Number)
    if (($Number % 2) -eq 0) {
        Write-Output $true
    }
    else {
        Write-Output $false
    }
}