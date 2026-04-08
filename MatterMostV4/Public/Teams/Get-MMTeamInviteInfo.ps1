# Получение информации о команде по invite_id

function Get-MMTeamInviteInfo {
    <#
    .SYNOPSIS
        Returns public team information for a given invite ID (no auth required by API, but session is used).
    .PARAMETER InviteId
        The invite ID to look up.
    .EXAMPLE
        Get-MMTeamInviteInfo -InviteId 'abc123invite'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InviteId
    )

    process {
        Invoke-MMRequest -Endpoint "teams/invite/$InviteId"
    }
}
