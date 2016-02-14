function ConvertTo-HexString {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
        [byte[]] $InputObject
    )

    BEGIN {
        $outString = New-Object -TypeName System.Text.StringBuilder
    }

    PROCESS {
        foreach ($byte in $InputObject) {
            [void]$outString.AppendFormat('{0:x2}', $byte)
        }
    }

    END {
        Write-Output $outString.ToString()
    }
}