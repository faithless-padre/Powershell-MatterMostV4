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

        [Parameter(Mandatory)]
        [string[]]$Permissions
    )

    process {
        Invoke-MMRequest -Endpoint "roles/$RoleId/patch" -Method PUT -Body @{
            permissions = $Permissions
        }
    }
}
