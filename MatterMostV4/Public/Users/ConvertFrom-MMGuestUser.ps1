# Повышение гостевого пользователя MatterMost до обычного

function ConvertFrom-MMGuestUser {
    <#
    .SYNOPSIS
        Повышает гостевого пользователя до обычного пользователя MatterMost (POST /users/{id}/promote).
    .EXAMPLE
        ConvertFrom-MMGuestUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser guest1 | ConvertFrom-MMGuestUser
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/promote" -Method POST | Add-MMTypeName -TypeName 'MatterMost.User'
    }
}
