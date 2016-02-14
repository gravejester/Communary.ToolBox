function Get-Entropy {
    <#
        .SYNOPSIS
            Calculate the entropy of a data set.
        .DESCRIPTION
            This function will calculate either the Shannon Entropy, or the
            Metric Entropy of a data set.
        .EXAMPLE
            Get-Entropy -InputObject $myArray
            Calculate the Shannon Entropy in the data in the myArray array.
        .EXAMPLE
            Get-Entropy -InputObject $myString -MetricEntropy
            Calculate the Metric Entropy of the string in the myString variable.
        .INPUTS
            System.String
            System.Array
        .OUTPUTS
            System.Double
        .NOTES
            Author: Øyvind Kallstad
            Date: 12.02.2016
            Version: 1.0
        .LINK
            https://en.wikipedia.org/wiki/Entropy_%28information_theory%29
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
    #>
    [CmdletBinding()]
    param (
        # A string or an array to calculate the entropy of.
        [Parameter(Mandatory = $true, Position = 0)]
        $InputObject,

        # If the input is a string, keep it case sensitive.
        [Parameter()]
        [switch] $CaseSensitive,

        # Metric Entropy will help you assess the randomness of the input. It will return
        # a value between 0 and 1, where 1 means that the data is equally distributed.
        [Parameter()]
        [switch] $MetricEntropy
    )

    try {
        if ($InputObject.Length -gt 1) {
            if ((-not($CaseSensitive)) -and ($InputObject.GetType().Name -eq 'String')) {
                $InputObject = $InputObject.ToLower()
            }

            # create a frequency array, counting each occurence of every element in the input array
            $frequencyArray = @{}
            foreach ($item in $inputObject.GetEnumerator()) {
                $frequencyArray[$item]++
            }

            $entropy = 0.0
            foreach ($item in $frequencyArray.GetEnumerator()) {
                # calculate the probability distribution by dividing the frequency with the total size of the data set
                $probabilityDistribution = $item.Value / $inputObject.Length
                # calculate the entropy by using the Shannon Entropy algorithm
                $entropy += $probabilityDistribution * [Math]::Log((1/$probabilityDistribution),2)
            }

            if ($MetricEntropy) {
                # calculate Metric Entropy by dividing the Shannon Entropy with the total size of the data set
                Write-Output ($entropy / $inputObject.Length)
            }
            else {
                Write-Output $entropy
            }
        }
        else {
            Write-Warning 'Size of data set is too small.'
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}