function Test-IsPerfectNumber {
    # https://en.wikipedia.org/wiki/Perfect_number
    # Test-IsPerfectNumber 8128
    # 496 | Test-IsPerfectNumber
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [uint32] $Number
    )

    $sumOfDivisors = 0
    foreach ($n in ($number | Get-Divisors)) {
        $sumOfDivisors += $n
    }

    if (($sumOfDivisors / 2) -eq $Number) {
        Write-Output $true
    }
    else {
        Write-Output $false
    }
}