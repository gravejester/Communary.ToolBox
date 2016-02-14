function ConvertTo-ScriptBlock{
    <#
        .SYNOPSIS
            Convert to ScriptBlock.
        .DESCRIPTION
            Convert input to ScriptBlock.
        .EXAMPLE
            Get-Content '.\scriptFile.ps1' -raw | ConvertTo-ScriptBlock
            Converts a script file to a ScriptBlock.
        .NOTES
            Author: Øyvind Kallstad
            Date: 13.03.2014
            Version: 1.0
    #>
	param (
        # Input you want converted to a ScriptBlock.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$InputObject
    )

    try {
        $scriptBlock = [ScriptBlock]::Create($inputObject)
    }

    catch {
        Write-Warning $_.Exception.Message
    }

    Write-Output $scriptBlock
}