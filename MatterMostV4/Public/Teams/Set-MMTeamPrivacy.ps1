# Изменение приватности команды MatterMost (open ↔ invite-only)

function Set-MMTeamPrivacy {
    <#
    .SYNOPSIS
        Изменяет приватность команды MatterMost: Open (открытая) или Invite (только по приглашению).
    .EXAMPLE
        Set-MMTeamPrivacy -TeamId 'abc123' -Privacy Invite
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Set-MMTeamPrivacy -Privacy Open
    #>
    [CmdletBinding()]
    [OutputType('MMTeam')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [ValidateSet('Open', 'Invite')]
        [string]$Privacy
    )

    process {
        $value = if ($Privacy -eq 'Open') { 'O' } else { 'I' }
        Invoke-MMRequest -Endpoint "teams/$TeamId/privacy" -Method PUT -Body @{ privacy = $value } |
            ConvertTo-MMTeam
    }
}
