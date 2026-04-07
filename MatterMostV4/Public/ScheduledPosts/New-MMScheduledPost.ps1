# Создание отложенного поста в MatterMost

function New-MMScheduledPost {
    <#
    .SYNOPSIS
        Creates a scheduled (delayed) post in a MatterMost channel.
    .DESCRIPTION
        Schedules a message to be sent at a specified time. Requires MatterMost server 10.3+.
        Requires create_post permission for the target channel.
    .PARAMETER ChannelId
        The ID of the channel to post in.
    .PARAMETER Message
        The message text. Supports Markdown formatting.
    .PARAMETER ScheduledAt
        The DateTime when the post should be sent.
    .PARAMETER RootId
        Optional post ID to reply to (for thread replies).
    .PARAMETER FileIds
        Optional array of file IDs to attach to the post.
    .OUTPUTS
        MMScheduledPost. The created scheduled post object.
    .EXAMPLE
        New-MMScheduledPost -ChannelId 'abc123' -Message 'Good morning!' -ScheduledAt (Get-Date '09:00')
    .EXAMPLE
        $ch = Get-MMChannel -Name 'announcements'
        New-MMScheduledPost -ChannelId $ch.Id -Message 'Weekly update' -ScheduledAt ((Get-Date).AddDays(7))
    #>
    [OutputType('MMScheduledPost')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [datetime]$ScheduledAt,

        [Parameter()]
        [string]$RootId,

        [Parameter()]
        [string[]]$FileIds
    )

    process {
        $scheduledAtMs = [System.DateTimeOffset]::new($ScheduledAt).ToUnixTimeMilliseconds()

        $body = @{
            channel_id   = $ChannelId
            message      = $Message
            scheduled_at = $scheduledAtMs
        }

        if ($RootId)   { $body['root_id']  = $RootId }
        if ($FileIds)  { $body['file_ids'] = $FileIds }

        Invoke-MMRequest -Endpoint 'posts/schedule' -Method POST -Body $body | ConvertTo-MMScheduledPost
    }
}
