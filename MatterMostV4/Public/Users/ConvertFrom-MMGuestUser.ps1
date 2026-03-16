# Повышение гостевого пользователя MatterMost до обычного

function ConvertFrom-MMGuestUser {
    <#
    .SYNOPSIS
        Promotes a guest user to a regular MatterMost user (POST /users/{id}/promote).
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
