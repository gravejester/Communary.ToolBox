function Get-GreatestCommonDivisor {
    # https://en.wikipedia.org/wiki/Euclidean_algorithm
    # https://en.wikipedia.org/wiki/Binary_GCD_algorithm
    # https://communary.wordpress.com/
    # https://github.com/gravejester/Communary.ToolBox
    # Get-GreatestCommonDivisor 1160718174 316258250 -Method Euclidean
    # Get-GreatestCommonDivisor 1160718174 316258250 -Method Stein
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [uint32] $a,

        [Parameter(Mandatory = $true, Position = 1)]
        [uint32] $b,

        [Parameter()]
        [ValidateSet('Euclidean','Stein')]
        [string] $Method = 'Euclidean'
    )

    if ($Method -eq 'Euclidean') {
        if ($b -eq 0) {
            Write-Output $a
        }
        else {
            Write-Output (Get-GreatestCommonDivisor $b ($a % $b) -Method Euclidean)
        }
    }
    else {
        $u = $a
        $v = $b

        if ($u -eq $v) {
            return $u
        }

        if ($u -eq 0) {
            return $v
        }

        if ($v -eq 0) {
            return $u
        }

        # if u is even
        if (Test-IsEven $u) {
            # if v is odd
            if (Test-IsOdd $v) {
                return (Get-GreatestCommonDivisor ($u -shr 1) $v -Method Stein)
            }
            # both u and v are even
            else {
                return ((Get-GreatestCommonDivisor ($u -shr 1) ($v -shr 1) -Method Stein) -shl 1)
            }
        }

        # if v is even
        if (Test-IsEven $v) {
            return (Get-GreatestCommonDivisor $u ($v -shr 1) -Method Stein)
        }

        # reduce larger argument
        if ($u -gt $v) {
            return (Get-GreatestCommonDivisor (($u - $v) -shr 1) $v -Method Stein)
        }

        return (Get-GreatestCommonDivisor (($v - $u) -shr 1) $u -Method Stein)
    }
}