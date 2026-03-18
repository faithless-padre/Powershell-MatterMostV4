# Получение списка команд пользователя MatterMost

function Get-MMUserTeams {
    <#
    .SYNOPSIS
        Returns the list of teams a MatterMost user belongs to.
    .DESCRIPTION
        Calls GET /users/{user_id}/teams to retrieve all teams the specified user is a member of.
        Accepts a user ID directly or resolves a username via Get-MMUser.
    .PARAMETER UserId
        The ID of the user. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER Username
        The username of the user. Used with the ByName parameter set.
    .OUTPUTS
        MMTeam. One or more team objects.
    .EXAMPLE
        Get-MMUserTeams -UserId 'abc123'
    .EXAMPLE
        Get-MMUserTeams -Username 'jdoe'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserTeams
    #>
    [OutputType('MMTeam')]
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Username
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMUser -Username $Username).id
        } else {
            $UserId
        }

        Invoke-MMRequest -Endpoint "users/$resolvedId/teams" | ConvertTo-MMTeam
    }
}
