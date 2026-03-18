# Удаление пользователя из канала MatterMost

function Remove-MMUserFromChannel {
    <#
    .SYNOPSIS
        Removes a user from a MatterMost channel.
    .DESCRIPTION
        Sends DELETE /channels/{channel_id}/members/{user_id}. The user loses access to the channel
        but the channel itself is not affected. Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER ChannelId
        The ID of the channel to remove the user from.
    .PARAMETER UserId
        The ID of the user to remove. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMUserFromChannel -ChannelId 'chan123' -UserId 'user456'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Remove-MMUserFromChannel -ChannelId 'chan123'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess("UserId=$UserId", "Remove from channel $ChannelId")) {
            Invoke-MMRequest -Endpoint "channels/$ChannelId/members/$UserId" -Method DELETE | Out-Null
        }
    }
}
