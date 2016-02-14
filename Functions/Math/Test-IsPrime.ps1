function Test-IsPrime {
    <#
        .SYNOPSIS
            Test if a number is a prime number.
        .DESCRIPTION
            This function uses the Rabin-Miller primality test to check for primality.
        .EXAMPLE
            Test-IsPrime 6461335109
            Returns True.
        .LINK
            http://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
            http://rosettacode.org/wiki/Miller-Rabin_primality_test#C.23
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .INPUTS
            bigint
        .NOTES
            This code is translated to PowerShell from code found on rosettacode.
            Author: Øyvind Kallstad
            Date: 11.05.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        # The number you want to check for primality.
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [bigint]$Number,

        # Determines the accuracy of the test. Default value is 40.
        [Parameter(Position = 1)]
        [ValidateRange(1,[int]::MaxValue)]
        [int]$Iterations = 40
    )

    if ($Number -in 2..3) {
        return $true
    }

    if (($Number -lt 2) -or (($Number % 2) -eq 0)) {
        return $false
    }

    [bigint]$d = $Number - 1
    [int]$s = 0

    while (($d % 2) -eq 0) {
        $d /= 2
        $s += 1
    }

    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    [byte[]] $bytes = $Number.ToByteArray().LongLength
    [bigint]$a = 0

    for ($i = 0; $i -lt $Iterations; $i++) {
        do {
            $rng.GetBytes($bytes)
            $a = [bigint]$bytes
        } while (($a -lt 2) -or ($a -ge ($Number - 2)))

        [bigint]$x = [bigint]::ModPow($a, $d, $Number)
        if (($x -eq 1) -or ($x -eq ($Number - 1))) {
            continue
        }

        for ($r = 1; $r -lt $s; $r++) {
            $x = [bigint]::ModPow($x, 2, $Number)
            if ($x -eq 1) {
                return $false
            }
            if ($x -eq ($Number - 1)) {
                break
            }
        }

        if ($x -ne ($Number - 1)) {
            return $false
        }
    }
    return $true
}