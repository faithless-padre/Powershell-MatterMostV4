# Перемещение канала MatterMost в другую команду

function Move-MMChannel {
    <#
    .SYNOPSIS
        Moves a MatterMost channel to a different team.
    .DESCRIPTION
        Sends POST /channels/{channel_id}/move to reassign the channel to another team.
        Requires system admin privileges. Supports -WhatIf / -Confirm via ShouldProcess.
    .PARAMETER ChannelId
        The ID of the channel to move. Accepts pipeline input by property name (id).
    .PARAMETER TeamId
        The ID of the destination team.
    .OUTPUTS
        MMChannel
    .EXAMPLE
        Move-MMChannel -ChannelId 'abc123' -TeamId 'team456'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Move-MMChannel -TeamId 'team456'
    #>
    [OutputType('MMChannel')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(Mandatory)]
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($ChannelId, "Move channel to team $TeamId")) {
            $body = @{ team_id = $TeamId }
            Invoke-MMRequest -Endpoint "channels/$ChannelId/move" -Method POST -Body $body | ConvertTo-MMChannel
        }
    }
}
