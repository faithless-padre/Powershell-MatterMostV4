# Disables a bot account in MatterMost

function Disable-MMBot {
    <#
    .SYNOPSIS
        Disables a MatterMost bot account.
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
