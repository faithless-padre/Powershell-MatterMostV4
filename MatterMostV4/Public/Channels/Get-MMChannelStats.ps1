# Получение статистики канала MatterMost

function Get-MMChannelStats {
    <#
    .SYNOPSIS
        Returns statistics for a MatterMost channel.
    .DESCRIPTION
        Sends GET /channels/{channel_id}/stats and returns an object with
        channel_id, member_count, guest_count, and pinnedpost_count.
    .PARAMETER ChannelId
        The ID of the channel. Accepts pipeline input by property name (id).
    .OUTPUTS
        PSCustomObject
    .EXAMPLE
        Get-MMChannelStats -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -Name 'town-square' | Get-MMChannelStats
    #>
    [OutputType('PSCustomObject')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        Invoke-MMRequest -Endpoint "channels/$ChannelId/stats"
    }
}
