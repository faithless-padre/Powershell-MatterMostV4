# Get-MMRole.ps1 — Получение ролей MatterMost по ID, имени, списку имён или всех сразу

function Get-MMRole {
    <#
    .SYNOPSIS
        Returns a MatterMost role by ID, name, list of names, or all roles.
    .DESCRIPTION
        Retrieves role objects containing permission lists. Use Get-MMRole to inspect
        which permissions are granted to system/team/channel roles before modifying them with Set-MMRole.
    .PARAMETER All
        Returns all roles in the system. Used with the All parameter set (default).
    .PARAMETER RoleId
        The ID of the role to retrieve. Used with the ById parameter set.
    .PARAMETER Name
        The name of the role, e.g. 'system_admin', 'team_user'. Used with the ByName parameter set.
    .PARAMETER Names
        An array of role names for batch lookup. Used with the ByNames parameter set.
    .OUTPUTS
        MMRole. One or more role objects including their permissions lists.
    .EXAMPLE
        Get-MMRole -All
    .EXAMPLE
        Get-MMRole -RoleId 'abc123'
    .EXAMPLE
        Get-MMRole -Name 'system_admin'
    .EXAMPLE
        Get-MMRole -Names 'system_admin', 'system_user', 'team_admin'
    #>
    [OutputType('MMRole')]
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$RoleId,

        [Parameter(Mandatory, ParameterSetName = 'ByName', Position = 0)]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ByNames')]
        [string[]]$Names
    )

    switch ($PSCmdlet.ParameterSetName) {
        'All'     { Invoke-MMRequest -Endpoint 'roles' | ConvertTo-MMRole }
        'ById'    { Invoke-MMRequest -Endpoint "roles/$RoleId" | ConvertTo-MMRole }
        'ByName'  { Invoke-MMRequest -Endpoint "roles/name/$Name" | ConvertTo-MMRole }
        'ByNames' { Invoke-MMRequest -Endpoint 'roles/names' -Method POST -Body $Names | ConvertTo-MMRole }
    }
}
