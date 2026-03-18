# Удобная обёртка для получения сообщений из лички, группы, канала или по ID

function Get-MMMessage {
    <#
    .SYNOPSIS
        Gets messages from a DM, group chat, channel by name, or by post ID(s).
    .DESCRIPTION
        A high-level wrapper around Get-MMChannelPosts, Get-MMPost, and channel resolution.
        Transparently creates or reuses DM/group channels when fetching messages by user(s).
        Use this instead of Get-MMChannelPosts when you want to work with usernames and channel names
        rather than raw IDs.
    .PARAMETER PostId
        The ID of a single post to retrieve. Used with the ById parameter set.
    .PARAMETER PostIds
        An array of post IDs for batch retrieval. Used with the ByIds parameter set.
    .PARAMETER FromUser
        The username of the user whose DM conversation to read. Used with the FromUser parameter set.
    .PARAMETER FromUserId
        The user ID for DM conversation. Used with the FromUserId parameter set. Accepts pipeline input by property name (id).
    .PARAMETER FromUsers
        Array of 2–7 usernames for a group message conversation. Used with the FromUsers parameter set.
    .PARAMETER FromChannel
        The channel name to read posts from. Used with the FromChannel parameter set.
    .PARAMETER Page
        The page number (0-based). Applies to channel/user message sets.
    .PARAMETER PerPage
        Number of posts per page. Default is 60.
    .PARAMETER Since
        Unix timestamp in milliseconds. Only posts created after this time are returned.
    .PARAMETER IncludeDeleted
        When specified, includes soft-deleted posts in the results.
    .OUTPUTS
        MMPost. One or more post objects.
    .EXAMPLE
        Get-MMMessage -PostId 'abc123'
    .EXAMPLE
        Get-MMMessage -PostIds @('abc123', 'def456')
    .EXAMPLE
        Get-MMMessage -FromUser 'john'
    .EXAMPLE
        Get-MMUser -Username 'john' | Get-MMMessage
    .EXAMPLE
        Get-MMMessage -FromUsers @('john', 'jane', 'bob')
    .EXAMPLE
        Get-MMMessage -FromChannel 'general' -PerPage 20
    #>
    [CmdletBinding(DefaultParameterSetName = 'FromChannel')]
    [OutputType('MMPost')]
    param(
        # Получить конкретный пост по ID
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$PostId,

        # Получить несколько постов по массиву ID
        [Parameter(Mandatory, ParameterSetName = 'ByIds')]
        [string[]]$PostIds,

        # Получить сообщения из лички с пользователем по username
        [Parameter(Mandatory, ParameterSetName = 'FromUser')]
        [string]$FromUser,

        # Получить сообщения из лички с пользователем по ID (поддержка пайпа из MMUser)
        [Parameter(Mandatory, ParameterSetName = 'FromUserId', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$FromUserId,

        # Получить сообщения из группового чата
        [Parameter(Mandatory, ParameterSetName = 'FromUsers')]
        [ValidateCount(2, 7)]
        [string[]]$FromUsers,

        # Получить сообщения из канала по имени
        [Parameter(Mandatory, ParameterSetName = 'FromChannel')]
        [string]$FromChannel,

        [Parameter(ParameterSetName = 'FromUser')]
        [Parameter(ParameterSetName = 'FromUserId')]
        [Parameter(ParameterSetName = 'FromUsers')]
        [Parameter(ParameterSetName = 'FromChannel')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'FromUser')]
        [Parameter(ParameterSetName = 'FromUserId')]
        [Parameter(ParameterSetName = 'FromUsers')]
        [Parameter(ParameterSetName = 'FromChannel')]
        [int]$PerPage = 60,

        [Parameter(ParameterSetName = 'FromUser')]
        [Parameter(ParameterSetName = 'FromUserId')]
        [Parameter(ParameterSetName = 'FromUsers')]
        [Parameter(ParameterSetName = 'FromChannel')]
        [long]$Since,

        [Parameter(ParameterSetName = 'FromUser')]
        [Parameter(ParameterSetName = 'FromUserId')]
        [Parameter(ParameterSetName = 'FromUsers')]
        [Parameter(ParameterSetName = 'FromChannel')]
        [switch]$IncludeDeleted
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {

            'ById' {
                Get-MMPost -PostId $PostId
            }

            'ByIds' {
                Get-MMPost -PostIds $PostIds
            }

            'FromUser' {
                $target    = Get-MMUser -Username $FromUser
                $channelId = (New-MMDirectChannel -UserId1 $script:MMSession.UserId -UserId2 $target.id).id
                $params    = @{ ChannelId = $channelId; Page = $Page; PerPage = $PerPage }
                if ($Since)          { $params['Since']          = $Since }
                if ($IncludeDeleted) { $params['IncludeDeleted'] = $true }
                Get-MMChannelPosts @params
            }

            'FromUserId' {
                $channelId = (New-MMDirectChannel -UserId1 $script:MMSession.UserId -UserId2 $FromUserId).id
                $params    = @{ ChannelId = $channelId; Page = $Page; PerPage = $PerPage }
                if ($Since)          { $params['Since']          = $Since }
                if ($IncludeDeleted) { $params['IncludeDeleted'] = $true }
                Get-MMChannelPosts @params
            }

            'FromUsers' {
                $targets   = Get-MMUser -Usernames $FromUsers
                $ids       = @($script:MMSession.UserId) + @($targets | Select-Object -ExpandProperty id)
                $channelId = (New-MMGroupChannel -UserIds $ids).id
                $params    = @{ ChannelId = $channelId; Page = $Page; PerPage = $PerPage }
                if ($Since)          { $params['Since']          = $Since }
                if ($IncludeDeleted) { $params['IncludeDeleted'] = $true }
                Get-MMChannelPosts @params
            }

            'FromChannel' {
                $channelId = (Get-MMChannel -Name $FromChannel).id
                $params    = @{ ChannelId = $channelId; Page = $Page; PerPage = $PerPage }
                if ($Since)          { $params['Since']          = $Since }
                if ($IncludeDeleted) { $params['IncludeDeleted'] = $true }
                Get-MMChannelPosts @params
            }
        }
    }
}
