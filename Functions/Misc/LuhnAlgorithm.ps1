function Get-LuhnChecksum {
    <#
        .SYNOPSIS
            Calculate the Luhn checksum of a number.
        .DESCRIPTION
            The Luhn algorithm or Luhn formula, also known as the "modulus 10" or "mod 10" algorithm, 
            is a simple checksum formula used to validate a variety of identification numbers, such as 
            credit card numbers, IMEI numbers, National Provider Identifier numbers in the US, and 
            Canadian Social Insurance Numbers. It was created by IBM scientist Hans Peter Luhn.
        .EXAMPLE
            Get-LuhnChecksum -Number 1234567890123452
            Calculate the Luch checksum of the number. The result should be 60.
        .INPUTS
            System.UInt64
        .NOTES
            Author: Øyvind Kallstad
            Date: 19.02.2016
            Version: 1.0
            Dependencies: ConvertTo-Digits
        .LINKS
            https://en.wikipedia.org/wiki/Luhn_algorithm
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [uint64] $Number
    )

    $digitsArray = ConvertTo-Digits -Number $Number
    [array]::Reverse($digitsArray)

    $sum = 0
    $index = 0

    foreach ($digit in $digitsArray) {
        if (($index % 2) -eq 0) {
            $doubledDigit = $digit * 2
            if (-not($doubledDigit -eq 0)) {
                $doubleDigitArray = ConvertTo-Digits -Number $doubledDigit
                $sum += ($doubleDigitArray | Measure-Object -Sum | Select-Object -ExpandProperty Sum)
            }
        }
        else {
            $sum += $digit
        }
        $index++
    }
    Write-Output $sum
}

function New-LuhnChecksumDigit {
    <#
        .SYNOPSIS
            Calculate the Luhn checksum digit for a number.
        .DESCRIPTION
            This function uses the Luhn algorithm to calculate the
            Luhn checksum digit for a (partial) number.
        .EXAMPLE
            New-LuhnChecksumDigit -PartialNumber 123456789012345
            This will get the checksum digit for the number. The result should be 2.
        .INPUTS
            System.UInt64
        .NOTES
            Author: Øyvind Kallstad
            Date: 19.02.2016
            Version: 1.0
            Dependencies: Get-LuhnCheckSum
        .LINKS
            https://en.wikipedia.org/wiki/Luhn_algorithm
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [uint64] $PartialNumber
    )

    $checksum = Get-LuhnCheckSum -Number $PartialNumber
    Write-Output (($checksum * 9) % 10)
}

function Test-IsLuhnValid {
    <#
        .SYNOPSIS
            Valdidate a number based on the Luhn Algorithm.
        .DESCRIPTION
            This function uses the Luhn algorithm to validate a number that includes
            the Luhn checksum digit.
        .EXAMPLE
            Test-IsLuhnValid -Number 1234567890123452
            This will validate whether the number is valid according to the Luhn Algorithm.
        .INPUTS
            System.UInt64
        .OUTPUTS
            System.Boolean
        .NOTES
            Author: Øyvind Kallstad
            Date: 19.02.2016
            Version: 1.0
            Dependencies: Get-LuhnCheckSum, ConvertTo-Digits
        .LINKS
            https://en.wikipedia.org/wiki/Luhn_algorithm
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [uint64] $Number
    )

    $numberDigits = ConvertTo-Digits -Number $Number
    $checksumDigit = $numberDigits[-1]
    $numberWithoutChecksumDigit = $numberDigits[0..($numberDigits.Count - 2)] -join ''
    $checksum = Get-LuhnCheckSum -Number $numberWithoutChecksumDigit

    if ((($checksum + $checksumDigit) % 10) -eq 0) {
        Write-Output $true
    }
    else {
        Write-Output $false
    }
}