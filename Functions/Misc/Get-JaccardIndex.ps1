function Get-JaccardIndex {
    <#
        .SYNOPSIS
            Get the Jaccard Index of two strings.
        .DESCRIPTION
            The Jaccard index measures similarity between finite sample sets, and is defined as the size of the 
            intersection divided by the size of the union of the sample sets.
        .EXAMPLE
            Get-JaccardIndex 'karolin' 'kharolin'
        .LINK
            http://en.wikipedia.org/wiki/Jaccard_index
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 03.11.2014
            Version: 1.0
            Dependencies: Get-Intersection, Get-Union
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $String1,
 
        [Parameter(Position = 1, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $String2,
 
        # Makes matches case-sensitive. By default, matches are not case-sensitive.
        [Parameter()]
        [switch] $CaseSensitive
    )
 
    try {
        # handle case insensitivity
        if (-not($CaseSensitive)) {
            $String1 = $String1.ToLowerInvariant()
            $String2 = $String2.ToLowerInvariant()
        }
 
        # get intersection size and union size of both strings
        $intersectionSize = (Get-Intersection $String1 $String2 -CaseSensitive:$CaseSensitive).Length
        $unionSize = (Get-Union $String1 $String2 -CaseSensitive:$CaseSensitive).Length
 
        # calculate jaccard index by dividing union size with intersection size
        Write-Output ($intersectionSize / $unionSize)
    }
 
    catch {
        Write-Warning $_.Exception.Message
    }
}