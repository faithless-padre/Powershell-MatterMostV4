# Приглашение пользователей в команду MatterMost по email

function Send-MMTeamInvite {
    <#
    .SYNOPSIS
        Sends an invitation to a MatterMost team by email address(es).
    .EXAMPLE
        Send-MMTeamInvite -TeamId 'abc123' -Emails 'user@example.com'
    .EXAMPLE
        Send-MMTeamInvite -TeamName 'myteam' -Emails 'user@example.com'
    .EXAMPLE
        Send-MMTeamInvite -TeamId 'abc123' -Emails 'user1@example.com', 'user2@example.com'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Send-MMTeamInvite -Emails 'user@example.com'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$TeamName,

        [Parameter(Mandatory)]
        [string[]]$Emails
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMTeam -Name $TeamName).id
        } else {
            $TeamId
        }

        Invoke-MMRequest -Endpoint "teams/$resolvedId/invite/email" -Method POST -Body $Emails
    }
}
