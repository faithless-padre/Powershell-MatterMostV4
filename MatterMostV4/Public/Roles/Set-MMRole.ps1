# Set-MMRole.ps1 — Изменение permissions роли MatterMost

function Set-MMRole {
    <#
    .SYNOPSIS
        Изменяет список permissions для указанной роли MatterMost.

    .EXAMPLE
        Set-MMRole -RoleId 'abc123' -Permissions 'create_post', 'read_channel'

    .EXAMPLE
        Get-MMRole -Name 'team_user' | Set-MMRole -Permissions 'create_post'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$RoleId,

        [string[]]$Permissions,

        # Произвольные поля — для новых или незадокументированных свойств API
        [hashtable]$Properties
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Permissions')) { $body['permissions'] = $Permissions }
        if ($Properties) {
            foreach ($key in $Properties.Keys) { $body[$key] = $Properties[$key] }
        }

        Invoke-MMRequest -Endpoint "roles/$RoleId/patch" -Method PUT -Body $body | Add-MMTypeName -TypeName 'MatterMost.Role'
    }
}
