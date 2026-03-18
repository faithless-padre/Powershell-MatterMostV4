# Возвращает список постов канала MatterMost с поддержкой пагинации

function Get-MMChannelPosts {
    <#
    .SYNOPSIS
        Returns posts for a MatterMost channel with optional pagination and filtering.
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
