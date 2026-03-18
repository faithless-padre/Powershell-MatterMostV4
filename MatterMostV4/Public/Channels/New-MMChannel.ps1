# Создание нового канала в MatterMost

function New-MMChannel {
    <#
    .SYNOPSIS
        Creates a new channel in a MatterMost team.
    .DESCRIPTION
        Calls POST /channels to create a public or private channel within a team. The team can be specified
        by ID, by name, or via the default team set with Connect-MMServer -DefaultTeam.
    .PARAMETER TeamId
        The ID of the team to create the channel in. Used with the ById parameter set.
        Falls back to the default team if omitted.
    .PARAMETER TeamName
        The name of the team. Used with the ByName parameter set.
    .PARAMETER Name
        The channel handle (URL slug). Must be lowercase with no spaces, e.g. 'dev-alerts'.
    .PARAMETER DisplayName
        The human-readable display name shown in the MatterMost UI.
    .PARAMETER Type
        Channel visibility: 'Public' (default) or 'Private'. Mapped to 'O' and 'P' internally.
    .PARAMETER Purpose
        A short description of the channel's purpose (shown in channel header).
    .PARAMETER Header
        Channel header text (supports markdown).
    .OUTPUTS
        MMChannel. The newly created channel object.
    .EXAMPLE
        New-MMChannel -TeamId 'team123' -Name 'mychannel' -DisplayName 'My Channel'
    .EXAMPLE
        New-MMChannel -TeamName 'myteam' -Name 'mychannel' -DisplayName 'My Channel'
    .EXAMPLE
        New-MMChannel -TeamId 'team123' -Name 'private' -DisplayName 'Private Channel' -Type Private
    #>
    [OutputType('MMChannel')]
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(ParameterSetName = 'ById')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$TeamName,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [ValidateSet('Public', 'Private')]
        [string]$Type = 'Public',

        [string]$Purpose,
        [string]$Header
    )

    $resolvedTeamId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        (Get-MMTeam -Name $TeamName).id
    } elseif ($TeamId) {
        $TeamId
    } else {
        Get-MMDefaultTeamId
    }

    $body = @{
        team_id      = $resolvedTeamId
        name         = $Name
        display_name = $DisplayName
        type         = if ($Type -eq 'Public') { 'O' } else { 'P' }
    }

    if ($Purpose) { $body['purpose'] = $Purpose }
    if ($Header)  { $body['header']  = $Header }

    Invoke-MMRequest -Endpoint 'channels' -Method POST -Body $body | ConvertTo-MMChannel
}
