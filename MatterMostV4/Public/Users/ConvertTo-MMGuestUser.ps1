# Понижение пользователя MatterMost до гостевого аккаунта

function ConvertTo-MMGuestUser {
    <#
    .SYNOPSIS
        Demotes a regular user to a guest in MatterMost (POST /users/{id}/demote).
    .DESCRIPTION
        Sends POST /users/{user_id}/demote to downgrade a full member to a guest account.
        Guest users have restricted access: they can only see channels they are explicitly added to
        and cannot browse or join other channels. Requires admin permissions.
    .PARAMETER UserId
        The ID of the user to demote. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMUser. The updated user object with the guest role.
    .EXAMPLE
        ConvertTo-MMGuestUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser testuser | ConvertTo-MMGuestUser
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/demote" -Method POST | ConvertTo-MMUser
    }
}
