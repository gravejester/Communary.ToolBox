function ConvertTo-BinaryString {
    # https://communary.wordpress.com/
    # https://github.com/gravejester/Communary.ToolBox
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
        [array] $InputObject,

        [Parameter()]
        [switch] $Pad
    )

    PROCESS {
        foreach ($item in $InputObject) {
            if ($item.GetType().Name -eq 'string') {
                [System.Text.Encoding]::ASCII.GetBytes($item) | ForEach-Object {
                    if ($Pad) {
                        Write-Output (([System.Convert]::ToString($_,2)).PadLeft(8,'0'))
                    }
                    else {
                        Write-Output ([System.Convert]::ToString($_,2))
                    }

                }
            }
            else {
                if ($Pad) {
                    Write-Output (([System.Convert]::ToString($item,2)).PadLeft(8,'0'))
                }
                else {
                    Write-Output ([System.Convert]::ToString($item,2))
                }

            }
        }
    }
}