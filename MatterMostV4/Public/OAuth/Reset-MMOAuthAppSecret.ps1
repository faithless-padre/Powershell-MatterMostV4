# Перегенерация client_secret для OAuth-приложения MatterMost

function Reset-MMOAuthAppSecret {
    <#
    .SYNOPSIS
        Regenerates the client secret for a MatterMost OAuth app.
    .EXAMPLE
        Reset-MMOAuthAppSecret -AppId 'abc123'
    .EXAMPLE
        Get-MMOAuthApp -AppId 'abc123' | Reset-MMOAuthAppSecret
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$AppId
    )

    process {
        Invoke-MMRequest -Endpoint "oauth/apps/$AppId/regen_secret" -Method POST
    }
}
