# Деактивация пользователя MatterMost

function Disable-MMUser {
    <#
    .SYNOPSIS
        Deactivates a MatterMost user (soft disable via PUT /active).
    .DESCRIPTION
        Sends PUT /users/{user_id}/active with active=false to deactivate the user account.
        The user cannot log in while deactivated but the account and all data are preserved.
        Use Enable-MMUser to reactivate. Requires admin permissions.
    .PARAMETER UserId
        The ID of the user to deactivate. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMUser. The updated user object showing the deactivated state.
    .EXAMPLE
        Disable-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser testuser | Disable-MMUser
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/active" -Method PUT -Body @{ active = $false } | ConvertTo-MMUser
    }
}
