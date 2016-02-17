function Test-IsPerfectNumber {
    <#
        .SYNOPSIS
            Test if a positive integer is a Perfect Number.
        .DESCRIPTION
            In number theory, a perfect number is a positive integer that is equal to the sum of its proper positive divisors.
        .EXAMPLE
            Test-IsPerfectNumber 8128
        .EXAMPLE
            496 | Test-IsPerfectNumber
        .INPUTS
            System.UInt32
        .OUTPUTS
            System.Boolean
        .NOTES
            Author: Øyvind Kallstad
            Date: 16.02.2016
            Version: 1.0
            Dependencies: Get-Divisors
        .LINK
            https://en.wikipedia.org/wiki/Perfect_number
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #> 
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [uint32] $Number
    )

    try {
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
    catch {
        Write-Warning $_.Exception.Message
    }
}