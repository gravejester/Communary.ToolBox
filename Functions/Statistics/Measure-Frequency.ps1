function Measure-Frequency {
    <#
        .SYNOPSIS
            Get the frequency distribution of a set.
        .DESCRIPTION
            This function will get the frequency distribution of a set (array) of data.
            It supports array types, as well as strings.
        .EXAMPLE
            Measure-Frequency $array
        .EXAMPLE
            Measure-Frequency $string -CaseSensitive
        .LINK
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 10.02.2016
            Version: 1.1
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        $InputObject,

        [Parameter()]
        [switch] $CaseSensitive
    )

    try {
        if ((-not($CaseSensitive)) -and ($InputObject.GetType().Name -eq 'String')) {
            $InputObject = $InputObject.ToLower()
        }
        $inputArray = $InputObject.GetEnumerator()
        $inputArray | Group-Object | Sort-Object -Descending -Property Count | ForEach-Object {

            $frequency = $_.Count / $inputObject.Length
            $percent = '{0:P0}' -f $frequency

            Write-Output ([PSCustomObject] [Ordered] @{
                Value = $_.Name
                Count = $_.Count
                Percent = $percent
                Frequency = $frequency
            })
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}