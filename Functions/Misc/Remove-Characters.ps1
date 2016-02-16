function Remove-Characters {
    <#
        .SYNOPSIS
            Remove characters from a string.
        .DESCRIPTION
            This function will take an array of characters, and will remove
            those characters from the input string.
        .EXAMPLE
            $myString | Remove-Characters
            This will remove all 'default' characters from myString.
        .EXAMPLE
            Remove-Characters -InputString $myString -Remove ([char[]](0..47 + 58..64 + 91..96 + 123..255 | ForEach-Object {[char]$_}))
            This will remove all characters in the ASCII table except letters and numbers.
        .EXAMPLE
            Remove-Characters -InputString $myString -Remove ([char[]](0..47 + 58..64 + 91..96 + 123..[int][char]::MaxValue | ForEach-Object {[char]$_}))
            This will remove all special characters with the exception of letters and numbers. NOTE This one is a bit slower than the other two examples.
        .INPUTS
            System.String
        .OUTPUTS
            System.String
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            This code was translated and adapted from this StackOverflow answer: http://stackoverflow.com/a/1120407/3940558
            Author: Øyvind Kallstad
            Date: 11.02.2016
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $InputString,

        # Characters to remove.
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [char[]] $Remove = ([char[]](0..47 + 58..64 + 91..96 + 123..255 | ForEach-Object {[char]$_}))
    )

    [char[]]$buffer = New-Object -TypeName System.Char[] -ArgumentList $InputString.Length
    $index = 0

    foreach ($character in $InputString.ToCharArray()) {
        if (-not ($Remove -contains $character)) {
            $buffer[$index] = $character
            $index++
        }
    }

    Write-Output (New-Object -TypeName System.String -ArgumentList ($buffer,0,$index))
}