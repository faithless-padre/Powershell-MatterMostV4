# Возвращает список постов канала MatterMost с поддержкой пагинации

function Get-MMChannelPosts {
    <#
    .SYNOPSIS
        Returns posts for a MatterMost channel with optional pagination and filtering.
    .EXAMPLE
        Get-MMChannelPosts -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -Name 'general' | Get-MMChannelPosts -Page 0 -PerPage 20
    .EXAMPLE
        Get-MMChannelPosts -ChannelId 'abc123' -Since 1700000000000
    #>
    [CmdletBinding()]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter()]
        [int]$Page = 0,

        [Parameter()]
        [int]$PerPage = 60,

        # Unix timestamp в миллисекундах — вернуть посты изменённые после этого момента
        [Parameter()]
        [long]$Since,

        [Parameter()]
        [switch]$IncludeDeleted
    )

    process {
        $query = "page=$Page&per_page=$PerPage"
        if ($Since)           { $query += "&since=$Since" }
        if ($IncludeDeleted)  { $query += "&include_deleted=true" }

        $response = Invoke-MMRequest -Endpoint "channels/$ChannelId/posts?$query"

        # API возвращает { order: [...], posts: { id: PostObject, ... } }
        if ($response.order -and $response.posts) {
            foreach ($postId in $response.order) {
                $response.posts.$postId | ConvertTo-MMPost
            }
        }
    }
}
