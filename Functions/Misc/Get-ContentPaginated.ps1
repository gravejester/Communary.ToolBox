function Get-ContentPaginated {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        $InputObject
    )
    if ($host.Name -eq 'ConsoleHost') {
        try {
            Get-Content $InputObject | Out-Host -Paging
        }

        catch {
        }
    }

    else {
        Write-Warning 'This function only works in the console host.'
    }
}

New-Alias -Name more -Value Get-ContentPaginated