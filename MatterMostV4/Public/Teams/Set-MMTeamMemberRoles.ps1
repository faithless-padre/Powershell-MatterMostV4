# Установка ролей участника команды MatterMost

function Set-MMTeamMemberRoles {
    <#
    .SYNOPSIS
        Sets the roles for a user in a MatterMost team.
    .PARAMETER TeamId
        The ID of the team. Accepts pipeline input by property name.
    .PARAMETER UserId
        The ID of the user whose roles to update.
    .PARAMETER Roles
        Space-separated role names, e.g. 'team_user team_admin'.
    .EXAMPLE
        Set-MMTeamMemberRoles -TeamId 'abc123' -UserId 'user456' -Roles 'team_user team_admin'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$Roles
    )

    process {
        if ($PSCmdlet.ShouldProcess("User '$UserId' in team '$TeamId'", "Set roles to '$Roles'")) {
            Invoke-MMRequest -Endpoint "teams/$TeamId/members/$UserId/roles" -Method PUT -Body @{ roles = $Roles } | Out-Null
        }
    }
}
