# Get-MMRole.ps1 — Получение ролей MatterMost по ID, имени, списку имён или всех сразу

function Get-MMRole {
    <#
    .SYNOPSIS
        Возвращает роль MatterMost по ID, имени, списку имён или все роли сразу.

    .EXAMPLE
        Get-MMRole -All

    .EXAMPLE
        Get-MMRole -RoleId 'abc123'

    .EXAMPLE
        Get-MMRole -Name 'system_admin'

    .EXAMPLE
        Get-MMRole -Names 'system_admin', 'system_user', 'team_admin'
    #>
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
        'All'     { Invoke-MMRequest -Endpoint 'roles' | Add-MMTypeName -TypeName 'MatterMost.Role' }
        'ById'    { Invoke-MMRequest -Endpoint "roles/$RoleId" | Add-MMTypeName -TypeName 'MatterMost.Role' }
        'ByName'  { Invoke-MMRequest -Endpoint "roles/name/$Name" | Add-MMTypeName -TypeName 'MatterMost.Role' }
        'ByNames' { Invoke-MMRequest -Endpoint 'roles/names' -Method POST -Body $Names | Add-MMTypeName -TypeName 'MatterMost.Role' }
    }
}
