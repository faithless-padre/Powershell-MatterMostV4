# Перемещение slash-команды MatterMost в другую команду (team)

function Move-MMCommand {
    <#
    .SYNOPSIS
        Moves a MatterMost slash command to another team (PUT /commands/{command_id}/move).
    .PARAMETER CommandId
        The ID of the command to move. Accepts pipeline input by property name (id).
    .PARAMETER TeamId
        The ID of the target team to move the command to.
    .EXAMPLE
        Move-MMCommand -CommandId 'cmd456' -TeamId 'team789'
    .EXAMPLE
        Get-MMCommand -CommandId 'cmd456' | Move-MMCommand -TeamId 'team789'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$CommandId,

        [Parameter(Mandatory)]
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($CommandId, "Move slash command to team '$TeamId'")) {
            Invoke-MMRequest -Endpoint "commands/$CommandId/move" -Method PUT -Body @{ team_id = $TeamId }
        }
    }
}
