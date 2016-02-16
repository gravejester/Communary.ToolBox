function Measure-ScriptBlock {
    <#
        .SYNOPSIS
            Measure time, memory consumption and CPU time for a block of code to execute.
        .DESCRIPTION
            Measure time, memory consumption and CPU time for a block of code to execute.
            This function is using Measure-Command internally, but is also trying to record how much memory and CPU time the code uses during execution.
        .EXAMPLE
            Measure-ScriptBlock -ScriptBlock {Get-ChildItem -Recurse} -Iteration 10 -TimeUnit 'Milliseconds' -SizeUnit 'KB'
            Run the code 10 times, formatting the mean values in Milliseconds and KB.
        .EXAMPLE
            Measure-ScriptBlock -ScriptBlock {Get-ChildItem -Recurse} -Iteration 10 -TimeUnit 'Milliseconds' -SizeUnit 'KB' -CalculateMeans:$false
            Run the same measurements are the above example, except skip calculating the mean value for the measurements taken.
        .EXAMPLE
            Measure-ScriptBlock -ScriptBlock $codeArray -Iteration 10 | Format-Table
            Run an array of script blocks 10 times, formatting the output in a table.
        .OUTPUTS
            System.Management.Automation.PSCustomObject
        .LINKS
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad
            Date: 28.10.2014
            Version: 1.0
    #>
    [CmdletBinding()]
    param (
        # Code to measure
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock[]] $ScriptBlock,

        # Set how many times you want to execute each ScriptBlock
        [Parameter()]
        [int32] $Iterations = 1,

        # Pause, in milliseconds, between each iteration
        [Parameter()]
        [int32] $Pause = 600,

        # Use this switch to control whether the mean values of each iteration should be calculated or not
        [Parameter()]
        [switch] $CalculateMeans = $true,

        # Customize the unit used for timings. Valid values are 'Hours','Minutes','Seconds' and 'Milliseconds'.
        [Parameter()]
        [ValidateSet('Hours','Minutes','Seconds','Milliseconds')]
        [string] $TimeUnit = 'Seconds',

        # Customize the unit of size. Valid values are 'KB','MB','GB' and 'TB'.
        [Parameter()]
        [ValidateSet('KB','MB','GB','TB')]
        [string] $SizeUnit = 'MB'
    )

    # initializing our counters - used by Write-Progress
    $arrayLength = $ScriptBlock.Count
    $totalCount = 0
    $arrayCount = 0

    # perform garbage collecting
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    [gc]::Collect()

    Start-Sleep -Seconds 1

    foreach ($script in $ScriptBlock) {
        $arrayCount++

        for ($i = 1; $i -le $Iterations; $i++) {

            # write progress bar
            $totalCount++
            Write-Progress -Activity 'Measuring' -Status "Executing ScriptBlock $($arrayCount)" -CurrentOperation "Iteration $($i)" -PercentComplete (($totalCount/($arrayLength*$iterations))*100)

            # perform garbage collecting
            [gc]::Collect()
            [gc]::WaitForPendingFinalizers()
            [gc]::Collect()

            # get current memory usage for current process
            $memBefore = [System.Diagnostics.Process]::GetCurrentProcess().PrivateMemorySize64

            # get current processor time for current process
            $cpuTimeBefore = [System.Diagnostics.Process]::GetCurrentProcess().TotalProcessorTime

            # run code
            $ttr = Measure-Command {
                $result = Invoke-Command -ScriptBlock $script
            } | Select-Object -ExpandProperty "Total$($TimeUnit)"
            $ttrArray += ,($ttr)

            # get current processor time for current process
            $cpuTimeAfter = [System.Diagnostics.Process]::GetCurrentProcess().TotalProcessorTime

            # get current memory usage for current process
            $memAfter = [System.Diagnostics.Process]::GetCurrentProcess().PrivateMemorySize64

            # do calculations
            $cpuTime = ($cpuTimeAfter | Select-Object -ExpandProperty "Total$($TimeUnit)") - ($cpuTimeBefore | Select-Object -ExpandProperty "Total$($TimeUnit)")
            $cpuTimeArray += ,($cpuTime)
            $memDifference = ($memAfter/"1$SizeUnit") - ($memBefore/"1$SizeUnit")
            if ($memDifference -lt 0) {$memDifference = 0} # just making sure we don't get a negative value
            $memDifferenceArray += ,($memDifference)

            if (-not($CalculateMeans)) {
                # if we don't want the calculated means we can
                # write the output to the pipeline after each iteration
                Write-Output ([PSCustomObject] [Ordered] @{
                    'ScriptBlock' = $script
                    'Result' = $result
                    'Iteration' = $i
                    "Memory ($($SizeUnit))" = ('{0:N0}' -f $memDifference)
                    "Processor Time ($($TimeUnit))" = ('{0:N2}' -f $cpuTime)
                    "Time To Run ($($TimeUnit))" = ('{0:N2}' -f $ttr)
                })
            }

            # a small pause before next iteration
            Start-Sleep -Milliseconds $Pause
        }

        # if we want the calculated means of our measurements,
        # we need to wait until all iterations are complete before
        # writing the output to the pipeline
        if ($CalculateMeans) {
            # create output object
            Write-Output ([PSCustomObject] [Ordered] @{
                'ScriptBlock' = $script
                'Result' = $result
                'Iterations' = $Iterations
                "Memory ($($SizeUnit))" = ('{0:N0}' -f ($memDifferenceArray | Measure-Object -Average | Select-Object -ExpandProperty Average))
                "Processor Time ($($TimeUnit))" = ('{0:N2}' -f ($cpuTimeArray | Measure-Object -Average | Select-Object -ExpandProperty Average))
                "Time To Run ($($TimeUnit))" = ('{0:N2}' -f ($ttrArray | Measure-Object -Average | Select-Object -ExpandProperty Average))
            })

            # reset the arrays
            Remove-Variable -Name memDifferenceArray,cpuTimeArray,ttrArray -ErrorAction SilentlyContinue
        }

    }

    # perform garbage collecting
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    [gc]::Collect()
}