# Назначение роли пользователю MatterMost

function Set-MMUserRole {
    <#
    .SYNOPSIS
        Назначает системные роли пользователю MatterMost.
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
