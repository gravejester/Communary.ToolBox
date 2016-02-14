function Test-IsHarshadNumber {
    <#
        .SYNOPSIS
            Check if a number is a Harshad number.
        .DESCRIPTION
            This function will check if a number is a Harshad number.
            A Harshad number is an integer that is divisible by the sum of its digits.
        .EXAMPLE
            11 | Test-IsHarshadNumber
            Test if 11 is a Harshad number.
        .EXAMPLE
            1..200 | ForEach-Object {if (Test-IsHarshadNumber $_) {$_}}
            List all Harshad numbers between 1 and 200.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
            Dependencies: ConvertTo-Digits
        .LINK
            http://en.wikipedia.org/wiki/Harshad_number
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .INPUTS
            System.Int32
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true)]
        [ValidateRange(1,[int]::MaxValue)]
        [int]$Number
    )
    [byte[]]$numberDigits = ConvertTo-Digits $Number
    if (($Number % $numberDigits.Sum()) -eq 0) {$true} else {$false}
}