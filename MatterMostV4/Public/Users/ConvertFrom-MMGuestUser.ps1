# Повышение гостевого пользователя MatterMost до обычного

function ConvertFrom-MMGuestUser {
    <#
    .SYNOPSIS
        Promotes a guest user to a regular MatterMost user (POST /users/{id}/promote).
    .DESCRIPTION
        Sends POST /users/{user_id}/promote to upgrade a guest account to a full member.
        After promotion, the user gains access to all teams and channels they are added to,
        and is no longer restricted by guest account limitations. Requires admin permissions.
    .PARAMETER UserId
        The ID of the guest user to promote. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMUser. The updated user object with the new role.
    .EXAMPLE
        ConvertFrom-MMGuestUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser guest1 | ConvertFrom-MMGuestUser
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/promote" -Method POST | ConvertTo-MMUser
    }
}
