function ConvertTo-Bytes {
    <#
        .SYNOPSIS
            Convert a string to bytes.
        .NOTES
            Author: Øyvind Kallstad
            Date: 13.02.2016
            Version: 1.0
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        # String to convert to bytes.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [Alias('String')]
        [string] $InputString,

        # Text encoding to use. Valid values are 'Default','ASCII','BigEndianUnicode','Unicode','UTF32','UTF7' and'UTF8'.
        # Default value is 'Default'.
        [Parameter()]
        [ValidateSet('Default','ASCII','BigEndianUnicode','Unicode','UTF32','UTF7','UTF8')]
        [string] $Encoding = 'Default'
    )
    Write-output ([System.Text.Encoding]::$Encoding.GetBytes($InputString))
}