# Активация деактивированного пользователя MatterMost

function Enable-MMUser {
    <#
    .SYNOPSIS
        Activates a deactivated MatterMost user.
    .DESCRIPTION
        Sends PUT /users/{user_id}/active with active=true to re-enable a previously deactivated account.
        The user can log in again immediately after activation. Requires admin permissions.
    .PARAMETER UserId
        The ID of the user to activate. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMUser. The updated user object showing the active state.
    .EXAMPLE
        Enable-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -UserId 'abc123' | Enable-MMUser
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/active" -Method PUT -Body @{ active = $true } | ConvertTo-MMUser
    }
}
