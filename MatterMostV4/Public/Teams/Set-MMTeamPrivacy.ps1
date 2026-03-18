# Изменение приватности команды MatterMost (open ↔ invite-only)

function Set-MMTeamPrivacy {
    <#
    .SYNOPSIS
        Updates MatterMost team privacy: Open or Invite-only.
    .DESCRIPTION
        Sends PUT /teams/{team_id}/privacy to switch between Open ('O') and Invite-only ('I') team types.
        Open teams allow any server user to join. Invite-only teams require explicit membership or an invitation.
    .PARAMETER TeamId
        The ID of the team to update. Accepts pipeline input by property name (id).
    .PARAMETER Privacy
        The desired privacy mode: 'Open' (anyone can join) or 'Invite' (invitation required).
    .OUTPUTS
        MMTeam. The updated team object.
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
