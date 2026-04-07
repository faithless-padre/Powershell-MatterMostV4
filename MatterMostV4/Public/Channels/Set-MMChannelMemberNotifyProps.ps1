# Изменение настроек уведомлений участника канала MatterMost

function Set-MMChannelMemberNotifyProps {
    <#
    .SYNOPSIS
        Updates notification preferences for a user in a MatterMost channel.
    .DESCRIPTION
        Sends PUT /channels/{channel_id}/members/{user_id}/notify_props to update
        per-channel notification settings. Only the parameters you explicitly pass
        will be included in the request body. Supports -WhatIf / -Confirm.
    .PARAMETER ChannelId
        The ID of the channel.
    .PARAMETER UserId
        The ID of the user whose notification props to update.
    .PARAMETER Desktop
        Desktop notification level: 'default', 'all', 'mention', or 'none'.
    .PARAMETER Email
        Email notification level: 'default', 'all', 'mention', or 'none'.
    .PARAMETER Push
        Mobile push notification level: 'default', 'all', 'mention', or 'none'.
    .PARAMETER MarkUnread
        Unread indicator: 'all' or 'mention'.
    .PARAMETER IgnoreChannelMentions
        Whether to ignore @channel mentions: 'default', 'on', or 'off'.
    .OUTPUTS
        None
    .EXAMPLE
        Set-MMChannelMemberNotifyProps -ChannelId 'abc123' -UserId 'user456' -Desktop 'mention'
    .EXAMPLE
        Set-MMChannelMemberNotifyProps -ChannelId 'abc123' -UserId 'user456' -Push 'none' -MarkUnread 'mention'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory)]
        [string]$UserId,

        [string]$Desktop,
        [string]$Email,
        [string]$Push,
        [string]$MarkUnread,
        [string]$IgnoreChannelMentions
    )

    process {
        if ($PSCmdlet.ShouldProcess("$UserId in $ChannelId", 'Update channel member notification props')) {
            $paramMap = @{
                Desktop                = 'desktop'
                Email                  = 'email'
                Push                   = 'push'
                MarkUnread             = 'mark_unread'
                IgnoreChannelMentions  = 'ignore_channel_mentions'
            }

            $body = @{}
            foreach ($param in $paramMap.Keys) {
                if ($PSBoundParameters.ContainsKey($param)) {
                    $body[$paramMap[$param]] = $PSBoundParameters[$param]
                }
            }

            Invoke-MMRequest -Endpoint "channels/$ChannelId/members/$UserId/notify_props" -Method PUT -Body $body | Out-Null
        }
    }
}
