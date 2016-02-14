Add-Type -TypeDefinition @"
   public enum PrimeMethods
   {
      Standard,
      SieveOfEratosthenes,
      SieveOfSundaram
   }
"@

function Get-PrimeNumbers {
    <#
        .SYNOPSIS
            Get Prime numbers.
        .DESCRIPTION
            This function will calculate the prime numbers from 2 to the amount specified using the
            Amount parameter. You have a choice of using three different methods to calculate the
            prime numbers; the Standard method, the Sieve Of Eratosthenes or the Sieve Of Sundaram.
        .EXAMPLE
            Get-PrimeNumbers 100
            This will list the first 100 prime numbers.
        .EXAMPLE
            Get-PrimeNumbers 100 -Method 'SieveOfEratosthenes'
            This will list the first 100 prime numbers using the Sieve Of Eratosthenes method.
        .NOTES
            These functions were translated from c# to PowerShell from a post on stackoverflow,
            written/collected by David Johnstone, but other authors were responsible for some of them.
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://stackoverflow.com/questions/1042902/most-elegant-way-to-generate-prime-numbers
            http://en.wikipedia.org/wiki/Sieve_of_Sundaram
            http://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
            http://en.wikipedia.org/wiki/Prime_number
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        # The amount of prime numbers to get. The default value is 10.
        [Parameter(Position = 0)]
        [ValidateRange(1,[int]::MaxValue)]
        [int] $Amount = 10,

        # The method used to get the prime numbers. Choices are 'Standard', 'SieveOfEratosthenes' and 'SieveOfSundaram'.
        # The default value is 'Standard'.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [PrimeMethods] $Method = 'Standard'
    )

    function Get-PrimeNumbersStandardMethod {
        param ([int]$Amount)

        $primes = New-Object System.Collections.ArrayList
        [void]$primes.Add(2)
        $nextPrime = 3
        while ($primes.Count -lt $Amount) {
            $squareRoot = [math]::Sqrt($nextPrime)
            $isPrime = $true
            for ($i = 0; $primes[$i] -le $squareRoot; $i++) {
                if (($nextPrime % $primes[$i]) -eq 0) {
                    $isPrime = $false
                    break
                }
            }
            if ($isPrime) {
                [void]$primes.Add($nextPrime)
            }
            $nextPrime += 2
        }
        Write-Output $primes
    }

    function Invoke-ApproximateNthPrime {
        param ([int]$nn)
        [double]$n = $nn
        [double]$p = 0
        if ($nn -ge 7022) {
            $p = $n * [math]::Log($n) + $n * ([math]::Log([math]::Log($n)) - 0.9385)
        }
        elseif ($nn -ge 6) {
            $p = $n * [math]::Log($n) + $n * [math]::Log([math]::Log($n))
        }
        elseif ($nn -gt 0) {
            $p = (2,3,5,7,11)[($nn - 1)]
        }
        Write-Output ([int]$p)
    }

    function Invoke-SieveOfEratosthenes {
        param([int]$Limit)
        $bits = New-Object -TypeName System.Collections.BitArray -ArgumentList (($Limit + 1), $true)
        $bits[0] = $false
        $bits[1] = $false
        for ($i = 0; ($i * $i) -le $Limit; $i++) {
            if ($bits[$i]) {
                for (($j = $i * $i); $j -le $Limit; $j += $i) {
                    $bits[$j] = $false
                }
            }
        }
        Write-Output (,($bits))
    }

    function Invoke-SieveOfSundaram {
        param([int]$Limit)
        $limit /= 2
        $bits = New-Object -TypeName System.Collections.BitArray -ArgumentList (($Limit + 1), $true)
        for ($i = 1; (3 * ($i + 1)) -lt $Limit; $i++) {
            for ($j = 1; ($i + $j + 2 * $i * $j) -le $Limit; $j++) {
                $bits[($i + $j + 2 * $i * $j)] = $false
            }
        }
        Write-Output (,($bits))
    }

    function Get-PrimeNumbersSieveOfEratosthenes {
        param([int]$Amount)
        $limit = Invoke-ApproximateNthPrime $Amount
        [System.Collections.BitArray]$bits = Invoke-SieveOfEratosthenes $limit
        $primes = New-Object System.Collections.ArrayList
        $found = 0
        for ($i = 0; $i -lt $limit -and $found -lt $Amount; $i++) {
            if ($bits[$i]) {
                [void]$primes.Add($i)
                $found++
            }
        }
        Write-Output $primes
    }
    function Get-PrimeNumbersSieveOfSundaram {
        param([int]$Amount)
        $limit = Invoke-ApproximateNthPrime $Amount
        [System.Collections.BitArray]$bits = Invoke-SieveOfSundaram $limit
        $primes = New-Object System.Collections.ArrayList
        [void]$primes.Add(2)
        $found = 1
        for ($i = 1; (2 * ($i + 1)) -le $limit -and $found -lt $Amount; $i++) {
            if ($bits[$i]) {
                [void]$primes.Add((2 * $i + 1))
                $found++
            }
        }
        Write-Output $primes
    }

    switch ($Method) {
        'Standard' {Get-PrimeNumbersStandardMethod $Amount;break}
        'SieveOfEratosthenes' {Get-PrimeNumbersSieveOfEratosthenes $Amount;break}
        'SieveOfSundaram' {Get-PrimeNumbersSieveOfSundaram $Amount;break}
    }
}