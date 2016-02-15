function Get-LeastCommonMultiple {
    # https://en.wikipedia.org/wiki/Least_common_multiple
    # Get-LeastCommonMultiple 21 6
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [uint32] $a,

        [Parameter(Mandatory = $true, Position = 1)]
        [uint32] $b
    )

    Write-Output (($a / (Get-GreatestCommonDivisor $a $b)) * $b)
}