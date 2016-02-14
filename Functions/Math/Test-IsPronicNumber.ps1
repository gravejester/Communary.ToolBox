function Test-IsPronicNumber {
    <#
        .SYNOPSIS
            Check if a number is a Pronic number.
        .DESCRIPTION
            This function will check if a number is a Pronic number.
            A pronic number is a number which is the product of two consecutive integers.
        .EXAMPLE
            2 | Test-IsPronicNumber
            Test if 2 is a Pronic Number.
        .EXAMPLE
            0..500 | ForEach-Object {if (Test-IsPronicNumber $_) {$_}}
            List all Pronic numbers between 0 and 500.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://en.wikipedia.org/wiki/Pronic_number
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .INPUTS
            System.Int32
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory = $true)]
        [ValidateRange(0,[int]::MaxValue)]
        [int]$Number
    )

    # We know 0 is a Pronic number, and since it will break
    # the math below, we handle it separately.
    if ($Number -eq 0) {
        Write-Output $true
    }

    else {
        # Get factors
        $n1 = [math]::Ceiling([math]::Sqrt($Number))
        $n2 = $Number / $n1
        # Check if factors are consecutive numbers
        if ((([math]::Min($n1, $n2)) + 1) -eq ([math]::Max($n1,$n2))) {
            Write-Output $true
        }
        else {
            Write-Output $false
        }
    }
}