# Получение закреплённых постов канала MatterMost

function Get-MMChannelPinnedPosts {
    <#
    .SYNOPSIS
        Returns all pinned posts in a MatterMost channel.
    .DESCRIPTION
        Sends GET /channels/{channel_id}/pinned. The response contains an order array
        and a posts map; this cmdlet flattens them into an ordered list of MMPost objects.
    .PARAMETER ChannelId
        The ID of the channel. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMPost
    .EXAMPLE
        Get-MMChannelPinnedPosts -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -Name 'town-square' | Get-MMChannelPinnedPosts
    #>
    [OutputType('MMPost')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        $raw = Invoke-MMRequest -Endpoint "channels/$ChannelId/pinned"
        foreach ($postId in $raw.order) {
            $raw.posts.$postId | ConvertTo-MMPost
        }
    }
}
