function Get-Factorial {
    <#
        .SYNOPSIS
            Get the factorial of a number.
        .DESCRIPTION
            Get the factorial of a number.
        .EXAMPLE
            Get-Factorial 5
            Get the factorial of 5.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
        .LINK
            http://en.wikipedia.org/wiki/Factorial
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateRange(0,[int]::MaxValue)]
        [int] $Number
    )
    if ($Number -eq 0) {
        Write-Output 1
    }
    else {
        Write-Output ($Number * (Get-Factorial ($Number - 1)))
    }
}