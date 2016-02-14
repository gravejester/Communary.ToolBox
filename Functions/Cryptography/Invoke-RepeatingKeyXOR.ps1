function Invoke-RepeatingKeyXOR {
    # http://cryptopals.com/sets/1/challenges/5/
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('String')]
        [string] $InputString,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string] $Key
    )

    try {
        $binaryString = $inputString | ConvertTo-Bytes
        $keyBinary = $Key | ConvertTo-Bytes

        $outputBytes = New-Object -TypeName System.Collections.ArrayList

        $keyIndex = 0
        foreach ($byte in $binaryString) {
            [void]$outputBytes.Add((($byte -bxor $keyBinary[$keyIndex])))
            $keyIndex++
            if ($keyIndex -gt ($keyBinary.Length - 1)) {
                $keyIndex = 0
            }
        }

        (Invoke-CryptBinaryToString -InputObject $outputBytes -Format Hex -NoCrLf).Replace(' ','') -join ''
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}