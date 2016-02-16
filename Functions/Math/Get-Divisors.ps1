function Get-Divisors {
    # Get-Divisors 6
    # Get-Divisors 28 | Sort-Object
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [uint32] $Number
    )
    
    for ($i = 1; ($i * $i) -le $Number; $i++) {
        if (($Number % $i) -eq 0) {
            Write-Output $i
            if (($i * $i) -ne $Number) {
                Write-Output ($Number / $i)
            }
        }
    }
}