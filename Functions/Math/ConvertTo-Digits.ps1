function ConvertTo-Digits {
    <#
        .SYNOPSIS
            Convert an integer into an array of bytes of its individual digits.
        .DESCRIPTION
            Convert an integer into an array of bytes of its individual digits.
        .EXAMPLE
            ConvertTo-Digits 145
        .INPUTS
            System.UInt64
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.05.2015
            Version: 1.0
    #>
    [OutputType([System.Byte[]])]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [uint64]$Number
    )
    $n = $Number
    $numberOfDigits = 1 + [convert]::ToUInt64([math]::Floor(([math]::Log10($n))))
    $digits = New-Object Byte[] $numberOfDigits
    for ($i = ($numberOfDigits - 1); $i -ge 0; $i--) {
        $digit = $n % 10
        $digits[$i] = $digit
        $n = [math]::Floor($n / 10)
    }
    Write-Output $digits
}