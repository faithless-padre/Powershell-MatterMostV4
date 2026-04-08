# Получение непрочитанных сообщений по командам MatterMost

function Get-MMTeamUnreads {
    <#
    .SYNOPSIS
        Returns unread message counts for teams for a given user.
        If TeamId is specified, returns unreads for that single team.
    .PARAMETER UserId
        The user ID to query unreads for. Defaults to 'me' (current user).
    .PARAMETER TeamId
        Optional. If provided, returns unreads for that specific team only.
    .EXAMPLE
        Get-MMTeamUnreads
    .EXAMPLE
        Get-MMTeamUnreads -UserId 'user123'
    .EXAMPLE
        Get-MMTeamUnreads -TeamId 'team456'
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$UserId = 'me',

        [Parameter()]
        [string]$TeamId
    )

    process {
        if ($TeamId) {
            Invoke-MMRequest -Endpoint "users/$UserId/teams/$TeamId/unread"
        }
        else {
            Invoke-MMRequest -Endpoint "users/$UserId/teams/unread?include_collapsed_threads=false"
        }
    }
}
