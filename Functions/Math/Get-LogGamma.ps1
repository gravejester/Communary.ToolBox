function Get-LogGamma {
    <#
        .SYNOPSIS
            Calculate Log-Gamma.
        .DESCRIPTION
            Because the gamma and factorial functions grow so rapidly for moderately large arguments,
            many computing environments include a function that returns the natural logarithm of the
            gamma function; this grows much more slowly, and for combinatorial calculations allows adding
            and subtracting logs instead of multiplying and dividing very large values.
        .EXAMPLE
            Get-LogGamma 10
        .LINK
            https://en.wikipedia.org/wiki/Gamma_function
            http://www.johndcook.com/Gamma.cs
            http://www.johndcook.com/stand_alone_code.html
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad (translated from code by John D. Cook)
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-Gamma
    #>
    param (
        [ValidateRange(0,[double]::MaxValue)]
        [double] $x
    )

    if ($x -lt 12.0) {
        return ([math]::Log([math]::Abs((Get-Gamma -x $x))))
    }

    # Abramowitz and Stegun 6.1.41
    # Asymptotic series should be good to at least 11 or 12 figures
    # For error analysis, see Whittiker and Watson
    # A Course in Modern Analysis (1927), page 252

    [double[]] $c = (
        (1.0/12.0),
        (-1.0/360.0),
        (1.0/1260.0),
        (-1.0/1680.0),
        (1.0/1188.0),
        (-691.0/360360.0),
        (1.0/156.0),
        (-3617.0/122400.0)
    )
    [double] $z = 1.0 / ($x * $x)
    [double] $sum = $c[7]

    for ($i = 6; $i -ge 0; $i--) {
        $sum *= $z
        $sum += $c[$i]
    }

    [double] $series = $sum / $x
    [double] $halfLogTwoPi = 0.91893853320467274178032973640562
    [double] $logGamma = ($x - 0.5) * [math]::Log($x) - $x + $halfLogTwoPi + $series
    Write-Output $logGamma
}