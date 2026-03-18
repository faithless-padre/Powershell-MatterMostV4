# Set-MMRole.ps1 — Изменение permissions роли MatterMost

function Set-MMRole {
    <#
    .SYNOPSIS
        Updates the permissions list for the specified MatterMost role.
    .DESCRIPTION
        Sends PUT /roles/{role_id}/patch to replace the role's permission list.
        The Permissions array completely replaces the existing permissions — include all desired
        permissions, not just the ones you want to add. Use Get-MMRole first to read the current list.
        Use -Properties for API fields not covered by named parameters.
    .PARAMETER RoleId
        The ID of the role to update. Accepts pipeline input by property name (id).
    .PARAMETER Permissions
        The full list of permission strings to assign to the role, e.g. 'create_post', 'read_channel'.
    .PARAMETER Properties
        A hashtable of additional API fields not covered by named parameters.
    .OUTPUTS
        MMRole. The updated role object.
    .EXAMPLE
        Set-MMRole -RoleId 'abc123' -Permissions 'create_post', 'read_channel'
    .EXAMPLE
        Get-MMRole -Name 'team_user' | Set-MMRole -Permissions 'create_post'
    #>
    [OutputType('MMRole')]
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

        Invoke-MMRequest -Endpoint "roles/$RoleId/patch" -Method PUT -Body $body | ConvertTo-MMRole
    }
}
