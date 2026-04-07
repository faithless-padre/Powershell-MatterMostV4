# Отметить канал как просмотренный для текущего пользователя

function Set-MMChannelViewed {
    <#
    .SYNOPSIS
        Marks a MatterMost channel as viewed for the current user.
    .DESCRIPTION
        Sends POST /channels/members/{user_id}/view to mark the channel as read.
        Optionally also marks a previous channel as viewed via -PrevChannelId.
        Supports -WhatIf / -Confirm via ShouldProcess.
    .PARAMETER ChannelId
        The ID of the channel to mark as viewed. Accepts pipeline input by property name (id).
    .PARAMETER PrevChannelId
        Optional ID of the previous channel to also mark as viewed.
    .OUTPUTS
        None
    .EXAMPLE
        Set-MMChannelViewed -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -Name 'town-square' | Set-MMChannelViewed
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [string]$PrevChannelId
    )

    process {
        if ($PSCmdlet.ShouldProcess($ChannelId, 'Mark channel as viewed')) {
            $userId = (Invoke-MMRequest -Endpoint 'users/me').id
            $body = @{ channel_id = $ChannelId }
            if ($PSBoundParameters.ContainsKey('PrevChannelId')) {
                $body['prev_channel_id'] = $PrevChannelId
            }
            Invoke-MMRequest -Endpoint "channels/members/$userId/view" -Method POST -Body $body | Out-Null
        }
    }
}
