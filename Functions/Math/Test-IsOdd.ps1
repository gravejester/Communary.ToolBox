function Test-IsOdd {
    # https://communary.wordpress.com/
    # https://github.com/gravejester/Communary.ToolBox
    param([uint32]$Number)
    if (($Number % 2) -eq 0) {
        Write-Output $false
    }
    else {
        Write-Output $true
    }
}