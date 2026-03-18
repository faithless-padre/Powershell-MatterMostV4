# Enables a disabled bot account in MatterMost

function Enable-MMBot {
    <#
    .SYNOPSIS
        Enables a disabled MatterMost bot account.
    .DESCRIPTION
        Sends a POST request to /bots/{bot_user_id}/enable to re-activate a previously disabled bot.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER BotUserId
        The user ID of the bot to enable. Accepts pipeline input by property name (user_id).
    .OUTPUTS
        MMBot. The updated bot object with enabled status.
    .EXAMPLE
        Enable-MMBot -BotUserId 'abc123'
    .EXAMPLE
        Get-MMBot -BotUserId 'abc123' | Enable-MMBot
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('user_id')]
        [string]$BotUserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($BotUserId, 'Enable bot')) {
            Invoke-MMRequest -Endpoint "bots/$BotUserId/enable" -Method POST | ConvertTo-MMBot
        }
    }
}
