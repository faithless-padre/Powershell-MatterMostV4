# Обновление отложенного поста MatterMost

function Set-MMScheduledPost {
    <#
    .SYNOPSIS
        Updates a scheduled post's message or scheduled time.
    .DESCRIPTION
        Updates the message and/or scheduled time of an existing scheduled post.
        Requires create_post permission for the channel the scheduled post belongs to.
        Requires MatterMost server 10.3+.
    .PARAMETER ScheduledPostId
        The ID of the scheduled post to update. Accepts pipeline input by property name (id).
    .PARAMETER ChannelId
        The channel ID. Required by the API — taken from the scheduled post when piping.
    .PARAMETER Message
        The new message text.
    .PARAMETER ScheduledAt
        The new DateTime when the post should be sent.
    .OUTPUTS
        MMScheduledPost. The updated scheduled post object.
    .EXAMPLE
        Set-MMScheduledPost -ScheduledPostId 'abc123' -ChannelId 'ch123' -Message 'Updated message' -ScheduledAt (Get-Date '10:00')
    .EXAMPLE
        Get-MMScheduledPost | Where-Object { $_.message -like '*old*' } | Set-MMScheduledPost -Message 'New message'
    #>
    [OutputType('MMScheduledPost')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ScheduledPostId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('channel_id')]
        [string]$ChannelId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Message,

        [Parameter()]
        [datetime]$ScheduledAt,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('scheduled_at')]
        [long]$ScheduledAtMs
    )

    process {
        $me = Invoke-MMRequest -Endpoint 'users/me'

        $resolvedScheduledAt = if ($ScheduledAt) {
            [System.DateTimeOffset]::new($ScheduledAt).ToUnixTimeMilliseconds()
        } else {
            $ScheduledAtMs
        }

        $body = @{
            id           = $ScheduledPostId
            channel_id   = $ChannelId
            user_id      = $me.id
            message      = $Message
            scheduled_at = $resolvedScheduledAt
        }

        Invoke-MMRequest -Endpoint "posts/schedule/$ScheduledPostId" -Method PUT -Body $body | ConvertTo-MMScheduledPost
    }
}
