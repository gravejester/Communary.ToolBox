function Test-Function {
    <#
        .SYNOPSIS
            This function will check for the existence of loaded functions.
        .DESCRIPTION
            This function will look at the currently loaded functions and report a true or false
            based on whether the functions are loaded or not, or list any missing functions if the
            ShowMissing parameter is used.
        .EXAMPLE
            Test-Function 'My-Function'
            Will return TRUE if 'My-Function' is found, or FALSE if it's not.
        .EXAMPLE
            Test-Function @('My-Function1','My-Function2')
            Will return TRUE if both functions are found, or FALSE if one, or both, are missing.
        .EXAMPLE
            Test-Function @('My-Function1','My-Function2') -ShowMissing
            Will return a list of any missing functions.
        .NOTES
            Author: Øyvind Kallstad
            Date: 18.04.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # Name of function(s) to check.
        [Parameter(ValueFromPipeline, Position = 0)]
        [string[]] $Name,

        # If 'true', will list any missing functions.
        [Parameter()]
        [switch] $ShowMissing = $false
    )

    BEGIN {
        $return = $true
        $missing = @()
    }

    PROCESS {
        foreach ($functionName in $Name) {
            if (-not(Test-Path -Path "function:\\$($functionName)")) {
                $return = $false
                $missing += $functionName
            }
        }
    }

    END {
        if ($ShowMissing) {
            Write-Output $missing
        }
        else {
            Write-Output $return
        }
    }
}