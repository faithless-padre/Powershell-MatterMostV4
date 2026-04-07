# Поиск пользователей MatterMost по строке поиска

function Search-MMUser {
    <#
    .SYNOPSIS
        Searches for MatterMost users by a search term.
    .PARAMETER Term
        The search term. Searches username, first name, last name, nickname, and email.
    .PARAMETER TeamId
        Limit results to users in this team.
    .PARAMETER InChannelId
        Limit results to users who are members of this channel.
    .PARAMETER NotInChannelId
        Limit results to users who are NOT members of this channel.
    .PARAMETER Limit
        Maximum number of results to return. Default is 100.
    .OUTPUTS
        MMUser
    .EXAMPLE
        Search-MMUser -Term 'john'
    .EXAMPLE
        Search-MMUser -Term 'admin' -Limit 5
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Term,

        [Parameter()]
        [string]$TeamId,

        [Parameter()]
        [string]$InChannelId,

        [Parameter()]
        [string]$NotInChannelId,

        [Parameter()]
        [int]$Limit = 100
    )

    process {
        $body = @{ term = $Term; limit = $Limit }
        if ($TeamId)          { $body['team_id']            = $TeamId }
        if ($InChannelId)     { $body['in_channel_id']      = $InChannelId }
        if ($NotInChannelId)  { $body['not_in_channel_id']  = $NotInChannelId }

        Invoke-MMRequest -Endpoint 'users/search' -Method POST -Body $body | ConvertTo-MMUser
    }
}
