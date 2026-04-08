# Сброс токена slash-команды MatterMost

function Reset-MMCommandToken {
    <#
    .SYNOPSIS
        Regenerates the token for a MatterMost slash command (PUT /commands/{command_id}/regen_token).
    .DESCRIPTION
        Generates a new verification token for the specified command.
        The old token is invalidated immediately.
    .PARAMETER CommandId
        The ID of the command whose token to regenerate. Accepts pipeline input by property name (id).
    .OUTPUTS
        PSCustomObject. Object with a 'token' property containing the new token.
    .EXAMPLE
        Reset-MMCommandToken -CommandId 'cmd456'
    .EXAMPLE
        Get-MMCommand -CommandId 'cmd456' | Reset-MMCommandToken
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$CommandId
    )

    process {
        if ($PSCmdlet.ShouldProcess($CommandId, 'Regenerate command token')) {
            Invoke-MMRequest -Endpoint "commands/$CommandId/regen_token" -Method PUT
        }
    }
}
