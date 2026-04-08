# Удаление иконки команды MatterMost

function Remove-MMTeamIcon {
    <#
    .SYNOPSIS
        Removes the custom icon for a MatterMost team, reverting to the default.
    .PARAMETER TeamId
        The ID of the team. Accepts pipeline input by property name.
    .EXAMPLE
        Remove-MMTeamIcon -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'dev' | Remove-MMTeamIcon
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($TeamId, 'Remove team icon')) {
            Invoke-MMRequest -Endpoint "teams/$TeamId/image" -Method DELETE | Out-Null
        }
    }
}
