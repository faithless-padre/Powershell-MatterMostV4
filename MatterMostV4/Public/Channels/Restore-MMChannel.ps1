# Восстановление удалённого (архивированного) канала MatterMost

function Restore-MMChannel {
    <#
    .SYNOPSIS
        Restores a deleted (archived) MatterMost channel.
    .DESCRIPTION
        Sends POST /channels/{channel_id}/restore to unarchive a previously deleted channel.
        Requires system admin or team admin privileges.
    .PARAMETER ChannelId
        The ID of the archived channel to restore. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMChannel. The restored channel object.
    .EXAMPLE
        Restore-MMChannel -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Restore-MMChannel
    #>
    [CmdletBinding()]
    [OutputType('MMChannel')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        Invoke-MMRequest -Endpoint "channels/$ChannelId/restore" -Method POST |
            ConvertTo-MMChannel
    }
}
