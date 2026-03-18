# Назначение роли пользователю MatterMost

function Set-MMUserRole {
    <#
    .SYNOPSIS
        Assigns system roles to a MatterMost user.
    .DESCRIPTION
        Sends PUT /users/{user_id}/roles to replace the user's system-level roles.
        Common role combinations: 'system_user' (regular user), 'system_admin system_user' (admin).
        Roles are provided as a space-separated string. This completely replaces existing roles.
        Requires system admin permissions.
    .PARAMETER UserId
        The ID of the user to update. Accepts pipeline input by property name (id).
    .PARAMETER Roles
        A space-separated string of role names to assign. Example: 'system_admin system_user'.
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Set-MMUserRole -UserId 'abc123' -Roles 'system_admin system_user'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Set-MMUserRole -Roles 'system_user'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$Roles
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/roles" -Method PUT -Body @{ roles = $Roles }
    }
}
