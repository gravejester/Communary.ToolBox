function Start-Timer {
    <#
        .SYNOPSIS
            Set the global timerStart variable.
        .EXAMPLE
            Start-Timer -Silent
            Will set the variable, and not output anything
        .EXAMPLE
            Write-Verbose (Start-Timer)
            Will set the variable, and write the start time to the verbose stream.
        .NOTES
            Author: Øyvind Kallstad
            Date: 19.04.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # Do not output anything.
        [Parameter()]
        [switch] $Silent = $false
    )
    $global:timerStart = Get-Date
    if (-not($Silent)) {
        Write-Output $global:timerStart
    }
}

function Stop-Timer {
    <#
        .SYNOPSIS
            Used together with Start-Timer to get a timespan between to instances and display in a human readable format.
        .EXAMPLE
            Stop-Timer
        .EXAMPLE
            Write-Verbose "Runtime: $(Stop-Timer)."
        .NOTES
            Author: Øyvind Kallstad
            Date: 19.04.2015
            Version: 1.0
    #>
    [CmdletBinding()]
    param ()

    $timerEnd = Get-Date
    if (Test-Path variable:\timerStart) {
        $timerResult = $timerEnd - $global:timerStart
        $resultString = $null
        switch ($res) {
            {$timerResult.Days -gt 0} {$resultString += ", $($timerResult.Hours) day$(@{$true = 's'}[$timerResult.Days -gt 1])"}
            {$timerResult.Hours -gt 0} {$resultString += ", $($timerResult.Hours) hour$(@{$true = 's'}[$timerResult.Hours -gt 1])"}
            {$timerResult.Minutes -gt 0} {$resultString += ", $($timerResult.Minutes) minute$(@{$true = 's'}[$timerResult.Minutes -gt 1])"}
            {$timerResult.Seconds -gt 0} {$resultString += ", $($timerResult.Seconds) second$(@{$true = 's'}[$timerResult.Seconds -gt 1])"}
            {$timerResult.Milliseconds -gt 0} {$resultString += ", $($timerResult.Milliseconds) millisecond$(@{$true = 's'}[$timerResult.Milliseconds -gt 1])"}
            DEFAULT {$resultString = $null}
        }
        Write-Output ($resultString.TrimStart(', '))
        Remove-Variable -Name 'timerStart' -Scope 'Global' -ErrorAction SilentlyContinue
    }
    else {
        Write-Output $null
    }
}