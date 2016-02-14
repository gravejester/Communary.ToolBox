function Get-Gamma {
    <#
        .SYNOPSIS
        .DESCRIPTION
        .EXAMPLE
            Get-Gamma 4
        .LINK
            http://www.johndcook.com/Gamma.cs
            http://www.johndcook.com/stand_alone_code.html
            http://en.wikipedia.org/wiki/Gamma_function
            https://communary.wordpress.com/
            https://github.com/gravejester/Communary.ToolBox
        .NOTES
            Author: Øyvind Kallstad (translated from code by John D. Cook)
            Date: 23.05.2015
            Version: 1.0
            Dependencies: Get-LogGamma
    #>
    param (
        [ValidateRange(0,[double]::MaxValue)]
        [double] $x
    )

    # First interval: (0, 0.001)

    # Euler's gamma constant
    [double]$gamma = 0.577215664901532860606512090

    if ($x -lt 0.001) {
        return (1.0 / ($x * (1.0 + $gamma * $x)))
    }

    # Second interval: (0.001, 12)

    if ($x -lt 12.0) {

        # The algorithm directly approximates gamma over (1,2) and uses
        # reduction identities to reduce other arguments to this interval.

        [double] $y = $x
        [int]$n = 0
        [bool]$argumentWasLessThanOne = ($y -lt 1.0)

        # Add or subtract integers as necessary to bring y into (1,2)
        # Will correct for this below
        if ($argumentWasLessThanOne) {
            $y += 1.0
        }
        else {
            $n = [int]([math]::Floor($y) - 1)
            $y -= $n
        }

        # numerator coefficients for approximation over the interval (1,2)
        [double[]] $p = (
           -1.71618513886549492533811E+0,
            2.47656508055759199108314E+1,
           -3.79804256470945635097577E+2,
            6.29331155312818442661052E+2,
            8.66966202790413211295064E+2,
           -3.14512729688483675254357E+4,
           -3.61444134186911729807069E+4,
            6.64561438202405440627855E+4
        )

        # denominator coefficients for approximation over the interval (1,2)
        [double[]] $q = (
           -3.08402300119738975254353E+1,
            3.15350626979604161529144E+2,
           -1.01515636749021914166146E+3,
           -3.10777167157231109440444E+3,
            2.25381184209801510330112E+4,
            4.75584627752788110767815E+3,
           -1.34659959864969306392456E+5,
           -1.15132259675553483497211E+5
        )

        [double] $num = 0.0
        [double] $den = 1.0
        [double] $z = $y - 1

        for ($i = 0; $i -lt 8; $i++) {
            $num = ($num + $p[$i]) * $z
            $den = $den * $z + $q[$i]
        }
        [double] $results = $num / $den + 1.0

        # Apply correction if argument was not initially in (1,2)
        if ($argumentWasLessThanOne) {
            # Use identity gamma(z) = gamma(z+1)/z
            # The variable "result" now holds gamma of the original y + 1
            # Thus we use y-1 to get back the orginal y.
            $results /= ($y - 1.0)
        }
        else {
            # Use the identity gamma(z+n) = z*(z+1)* ... *(z+n-1)*gamma(z)
            for ($i = 0; $i -lt $n; $i++) {
                $results *= $y++
            }
        }

        return $results
    }

    # Third interval: (12, infinity)

    if ($x -gt 171.624) {
        # Correct answer too large to display.
        return ([double]::PositiveInfinity)
    }

    return ([math]::Exp((Get-LogGamma $x)))
}