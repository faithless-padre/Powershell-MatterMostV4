# Приглашение пользователей в команду MatterMost по email

function Send-MMTeamInvite {
    <#
    .SYNOPSIS
        Отправляет приглашение в команду MatterMost по email-адресам.
    .EXAMPLE
        Send-MMTeamInvite -TeamId 'abc123' -Emails 'user@example.com'
    .EXAMPLE
        Send-MMTeamInvite -TeamId 'abc123' -Emails 'user1@example.com', 'user2@example.com'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Send-MMTeamInvite -Emails 'user@example.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [string[]]$Emails
    )

    process {
        Invoke-MMRequest -Endpoint "teams/$TeamId/invite/email" -Method POST -Body $Emails
    }
}
