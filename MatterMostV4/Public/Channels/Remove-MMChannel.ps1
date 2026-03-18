# Удаление (архивирование) канала MatterMost

function Remove-MMChannel {
    <#
    .SYNOPSIS
        Archives a MatterMost channel.
    .DESCRIPTION
        Sends DELETE /channels/{channel_id} to archive (soft-delete) the channel.
        Archived channels are hidden from users but not permanently deleted.
        Use Restore-MMChannel to unarchive. Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER ChannelId
        The ID of the channel to archive. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMChannel -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Remove-MMChannel
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        if ($PSCmdlet.ShouldProcess($ChannelId, 'Archive channel')) {
            Invoke-MMRequest -Endpoint "channels/$ChannelId" -Method DELETE
        }
    }
}
