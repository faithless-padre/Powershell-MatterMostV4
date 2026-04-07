# Конвертация пользователя MatterMost в бот-аккаунт

function ConvertTo-MMBotAccount {
    <#
    .SYNOPSIS
        Converts a MatterMost user account to a bot account.
    .DESCRIPTION
        Converts a user account to a bot account. This is irreversible. The user will no longer
        be able to log in. The account becomes a bot managed via the Bots API.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER UserId
        The ID of the user to convert. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void
    .EXAMPLE
        ConvertTo-MMBotAccount -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'mybot' | ConvertTo-MMBotAccount
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Convert user to bot account (irreversible)')) {
            Invoke-MMRequest -Endpoint "users/$UserId/convert_to_bot" -Method POST | Out-Null
        }
    }
}
