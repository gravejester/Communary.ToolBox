function Show-BinaryFile {
    <#
        .SYNOPSIS
            Binary file viewer.
        .DESCRIPTION
            This function will read and output a HEX and ASCII representation of a
            binary file, similar to hex editors.
        .EXAMPLE
            Show-BinaryFile -Path 'c:\path\to\binary.file'
            This will read and output the entire binary file.
        .EXAMPLE
            Show-BinaryFile -Path 'c:\path\to\binary.file' -Start 16 -Length 64
            This will read 64 bytes starting at position 16, and output the results.
        .NOTES
            Author: Øyvind Kallstad
            Date: 09.02.2016
            Version: 1.0
            Dependencies: Invoke-CryptBinaryToString
        .LINK
            https://communary.wordpress.com/
    #>
    [CmdletBinding()]
    param (
        # The path to the file you want to read.
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        # Start position for read operation.
        [Parameter(Position = 1)]
        [ValidateRange(0,[int]::MaxValue)]
        [int] $Start = 0,

        # The length of the read operation.
        [Parameter(Position = 2)]
        [ValidateRange(0,[int]::MaxValue)]
        [int] $Length = 0,

        # Indicate whether you want an address portion added to the output.
        [Parameter(Position = 3)]
        [switch] $ShowAddress
    )

    if (Test-Path -Path $Path) {
        try {
            $resolvedPath = Resolve-Path -Path $Path

            $fileStream = New-Object -TypeName System.IO.FileStream -ArgumentList ($resolvedPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
            $fileReader = New-Object -TypeName System.IO.BinaryReader -ArgumentList $fileStream

            if ($Length -eq 0) {
                $Length = $fileReader.BaseStream.Length
            }

            $fileReader.BaseStream.Position = $Start
            [byte[]]$readBytes = $fileReader.ReadBytes($Length)

            if ($ShowAddress) {
                $readBytes | Invoke-CryptBinaryToString -Format HexASCIIAddr
            }
            else {
                $readBytes | Invoke-CryptBinaryToString -Format HexASCII
            }
        }

        catch {
            Write-Warning $_.Exception.Message
        }

        finally {
            $fileReader.Dispose()
            $fileStream.Dispose()
        }
    }

    else { Write-Warning "$Path not found!" }
}