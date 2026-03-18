# Возвращает список постов канала MatterMost с поддержкой пагинации

function Get-MMChannelPosts {
    <#
    .SYNOPSIS
        Returns posts for a MatterMost channel with optional pagination and filtering.
    .DESCRIPTION
        Calls GET /channels/{channel_id}/posts to retrieve posts in chronological order.
        Supports lookup by channel ID or channel name. Use -Since to fetch only posts newer
        than a given Unix timestamp in milliseconds.
    .PARAMETER ChannelId
        The ID of the channel. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER ChannelName
        The name of the channel. Used with the ByName parameter set.
    .PARAMETER TeamId
        The team ID to scope the channel name lookup. Used with the ByName parameter set.
    .PARAMETER Page
        The page number (0-based) for paginated results. Default is 0.
    .PARAMETER PerPage
        The number of posts per page. Default is 60.
    .PARAMETER Since
        Return only posts created after this Unix timestamp in milliseconds.
    .PARAMETER IncludeDeleted
        When specified, soft-deleted posts are included in the results.
    .OUTPUTS
        MMPost. One or more post objects ordered by creation time.
    .EXAMPLE
        Get-MMChannelPosts -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannelPosts -ChannelName 'general'
    .EXAMPLE
        Get-MMChannel -Name 'general' | Get-MMChannelPosts -Page 0 -PerPage 20
    .EXAMPLE
        Get-MMChannelPosts -ChannelId 'abc123' -Since 1700000000000
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$ChannelName,

        [Parameter(ParameterSetName = 'ByName')]
        [string]$TeamId,

        [Parameter()]
        [int]$Page = 0,

        [Parameter()]
        [int]$PerPage = 60,

        [Parameter()]
        [long]$Since,

        [Parameter()]
        [switch]$IncludeDeleted
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMChannel -Name $ChannelName -TeamId $TeamId).id
        } else {
            $ChannelId
        }

        $query = "page=$Page&per_page=$PerPage"
        if ($Since)          { $query += "&since=$Since" }
        if ($IncludeDeleted) { $query += "&include_deleted=true" }

        $response = Invoke-MMRequest -Endpoint "channels/$resolvedId/posts?$query"

        if ($response.order -and $response.posts) {
            foreach ($postId in $response.order) {
                $response.posts.$postId | ConvertTo-MMPost
            }
        }
    }
}
