# Enables a disabled bot account in MatterMost

function Enable-MMBot {
    <#
    .SYNOPSIS
        Enables a disabled MatterMost bot account.
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
