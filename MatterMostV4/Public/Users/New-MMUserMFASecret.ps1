# Генерация нового MFA-секрета для пользователя MatterMost

function New-MMUserMFASecret {
    <#
    .SYNOPSIS
        Generates a new MFA secret and QR code for a MatterMost user.
    .DESCRIPTION
        Calls POST /users/{user_id}/mfa/generate to generate a new TOTP secret.
        Returns an object with 'secret' (the shared secret) and 'qr_code' (base64-encoded PNG).
        Use the secret or QR code with an authenticator app, then activate MFA via Set-MMUserMFA.
    .PARAMETER UserId
        The ID of the user. Accepts pipeline input by property name (id).
    .OUTPUTS
        PSObject. Contains 'secret' (string) and 'qr_code' (base64 PNG string).
    .EXAMPLE
        $mfa = New-MMUserMFASecret -UserId 'abc123'
        $mfa.secret
    .EXAMPLE
        Get-MMUser -Me | New-MMUserMFASecret
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/mfa/generate" -Method POST
    }
}
