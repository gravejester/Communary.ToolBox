function Invoke-Base64UrlEncode {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            http://blog.securevideo.com/2013/06/04/implementing-json-web-tokens-in-net-with-a-base-64-url-encoded-key/
            Author: Øyvind Kallstad
            Date: 23.03.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [byte[]] $Argument
    )

    $output = [System.Convert]::ToBase64String($Argument)
    $output = $output.Split('=')[0]
    $output = $output.Replace('+', '-')
    $output = $output.Replace('/', '_')

    Write-Output $output
}