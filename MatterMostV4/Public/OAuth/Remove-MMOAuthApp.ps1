# Удаление OAuth-приложения из MatterMost

function Remove-MMOAuthApp {
    <#
    .SYNOPSIS
        Deletes an OAuth app from MatterMost.
    .EXAMPLE
        Remove-MMOAuthApp -AppId 'abc123'
    .EXAMPLE
        Get-MMOAuthApp -AppId 'abc123' | Remove-MMOAuthApp
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$AppId
    )

    process {
        Invoke-MMRequest -Endpoint "oauth/apps/$AppId" -Method DELETE | Out-Null
    }
}
