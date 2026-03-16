# Понижение пользователя MatterMost до гостевого аккаунта

function ConvertTo-MMGuestUser {
    <#
    .SYNOPSIS
        Понижает обычного пользователя до гостевого в MatterMost (POST /users/{id}/demote).
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
