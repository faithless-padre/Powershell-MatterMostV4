# Disables a bot account in MatterMost

function Disable-MMBot {
    <#
    .SYNOPSIS
        Disables a MatterMost bot account.
    .DESCRIPTION
        Sends a POST request to /bots/{bot_user_id}/disable to deactivate the bot.
        The bot remains in the system but will not be able to authenticate or post messages.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER BotUserId
        The user ID of the bot to disable. Accepts pipeline input by property name (user_id).
    .OUTPUTS
        MMBot. The updated bot object with disabled status.
    .EXAMPLE
        Disable-MMBot -BotUserId 'abc123'
    .EXAMPLE
        Get-MMBot -BotUserId 'abc123' | Disable-MMBot
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('user_id')]
        [string]$BotUserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($BotUserId, 'Disable bot')) {
            Invoke-MMRequest -Endpoint "bots/$BotUserId/disable" -Method POST | ConvertTo-MMBot
        }
    }
}
