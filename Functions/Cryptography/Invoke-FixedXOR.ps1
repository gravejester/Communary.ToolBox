function Invoke-FixedXOR {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [byte[]] $ByteArrayOne,

        [Parameter(Mandatory = $true, Position = 1)]
        [byte[]] $ByteArrayTwo
    )
    $combinedBytes = New-Object System.Collections.ArrayList

    if ($ByteArrayOne.Length -eq $ByteArrayTwo.Length) {

        for ($index = 0; $index -lt $ByteArrayOne.Length; $index++) {
            [void]$combinedBytes.Add(($ByteArrayOne[$index] -bxor $ByteArrayTwo[$index]))
        }

        Write-Output $combinedBytes
    }
    else {
        Write-Warning 'Different length!'
    }
}