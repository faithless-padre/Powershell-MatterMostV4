# Создание новой команды (team) в MatterMost

function New-MMTeam {
    <#
    .SYNOPSIS
        Создаёт новую команду в MatterMost.
    .EXAMPLE
        New-MMTeam -Name 'myteam' -DisplayName 'My Team'
    .EXAMPLE
        New-MMTeam -Name 'privateteam' -DisplayName 'Private Team' -Type Invite
    #>
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

    Invoke-MMRequest -Endpoint 'teams' -Method POST -Body $body | Add-MMTypeName -TypeName 'MatterMost.Team'
}
