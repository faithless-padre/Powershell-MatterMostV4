# Возвращает посты, отмеченные пользователем как избранные (flagged)

function Get-MMFlaggedPosts {
    <#
    .SYNOPSIS
        Returns posts flagged by the specified user.
    .DESCRIPTION
        Calls GET /users/{user_id}/posts/flagged to retrieve posts that the user has bookmarked.
        Results can be filtered by team or channel. Defaults to the current user and the session
        default team.
    .PARAMETER UserId
        The user whose flagged posts to retrieve. Defaults to the current authenticated user.
    .PARAMETER TeamId
        Filter results to posts in this team. Defaults to the session default team.
    .PARAMETER ChannelId
        Filter results to posts in this channel. When omitted no channel filter is applied.
    .PARAMETER Page
        The page number (0-based) for paginated results. Default is 0.
    .PARAMETER PerPage
        The number of posts per page. Default is 60.
    .OUTPUTS
        MMPost. Zero or more flagged post objects.
    .EXAMPLE
        Get-MMFlaggedPosts
    .EXAMPLE
        Get-MMFlaggedPosts -ChannelId 'abc123'
    .EXAMPLE
        Get-MMFlaggedPosts -Page 1 -PerPage 20
    #>
    [CmdletBinding()]
    [OutputType('MMPost')]
    param(
        [Parameter()]
        [string]$UserId,

        [Parameter()]
        [string]$TeamId,

        [Parameter()]
        [string]$ChannelId,

        [Parameter()]
        [int]$Page = 0,

        [Parameter()]
        [int]$PerPage = 60
    )

    process {
        if (-not $UserId) {
            $UserId = (Invoke-MMRequest -Endpoint 'users/me').id
        }
        if (-not $TeamId) { $TeamId = Get-MMDefaultTeamId }

        $query = "team_id=$TeamId&page=$Page&per_page=$PerPage"
        if ($ChannelId) { $query += "&channel_id=$ChannelId" }

        $raw = Invoke-MMRequest -Endpoint "users/$UserId/posts/flagged?$query"

        if ($raw.order -and $raw.posts) {
            foreach ($postId in $raw.order) {
                $raw.posts.$postId | ConvertTo-MMPost
            }
        }
    }
}
