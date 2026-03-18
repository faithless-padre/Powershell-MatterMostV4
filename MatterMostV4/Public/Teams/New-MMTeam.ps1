# Создание новой команды (team) в MatterMost

function New-MMTeam {
    <#
    .SYNOPSIS
        Creates a new team in MatterMost.
    .DESCRIPTION
        Sends POST /teams to create a new team with the specified name, display name, and type.
        Team name must be lowercase alphanumeric with hyphens (used in URLs). Display name is what users see.
    .PARAMETER Name
        The URL-friendly name of the team (lowercase, alphanumeric, hyphens). Must be unique across the server.
    .PARAMETER DisplayName
        The human-readable display name of the team shown in the UI.
    .PARAMETER Type
        Team visibility: 'Open' allows anyone to join; 'Invite' requires an invitation. Defaults to 'Open'.
    .PARAMETER Description
        An optional description of the team displayed in team settings.
    .OUTPUTS
        MMTeam. The newly created team object.
    .EXAMPLE
        New-MMTeam -Name 'myteam' -DisplayName 'My Team'
    .EXAMPLE
        New-MMTeam -Name 'privateteam' -DisplayName 'Private Team' -Type Invite
    #>
    [OutputType('MMTeam')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        # Open — открытая команда, Invite — только по приглашению
        [ValidateSet('Open', 'Invite')]
        [string]$Type = 'Open',

        [string]$Description
    )

    $body = @{
        name         = $Name
        display_name = $DisplayName
        type         = if ($Type -eq 'Open') { 'O' } else { 'I' }
    }

    if ($Description) { $body['description'] = $Description }

    Invoke-MMRequest -Endpoint 'teams' -Method POST -Body $body | ConvertTo-MMTeam
}
