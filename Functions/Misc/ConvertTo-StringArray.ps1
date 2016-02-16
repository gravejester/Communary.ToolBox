function ConvertTo-StringArray {
    <#
        .SYNOPSIS
            Split a string on newline to produce a string array.
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 07.01.2016
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [string] $InputString
    )

    Write-Output ($InputString -Split '\r\n')
}