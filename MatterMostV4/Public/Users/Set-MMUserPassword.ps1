# Смена пароля пользователя MatterMost

function Set-MMUserPassword {
    <#
    .SYNOPSIS
        Changes a MatterMost user password.
    .DESCRIPTION
        Sends PUT /users/{user_id}/password to change the user's login password.
        Admins can change any user's password by providing only -NewPassword.
        Regular users changing their own password must also provide -CurrentPassword.
        Both passwords are passed as SecureString and never stored or logged as plaintext.
    .PARAMETER UserId
        The ID of the user whose password to change. Accepts pipeline input by property name (id).
    .PARAMETER NewPassword
        The new password as a SecureString.
    .PARAMETER CurrentPassword
        The current password as a SecureString. Required when a non-admin user changes their own password.
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Set-MMUserPassword -UserId 'abc123' -NewPassword (ConvertTo-SecureString 'NewPass123!' -AsPlainText -Force)
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Set-MMUserPassword -NewPassword (ConvertTo-SecureString 'NewPass123!' -AsPlainText -Force)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [SecureString]$NewPassword,

        # Требуется только если меняем пароль своей учётной записи (не админ)
        [SecureString]$CurrentPassword
    )

    process {
        $body = @{
            new_password = [PSCredential]::new('x', $NewPassword).GetNetworkCredential().Password
        }

        if ($CurrentPassword) {
            $body['current_password'] = [PSCredential]::new('x', $CurrentPassword).GetNetworkCredential().Password
        }

        Invoke-MMRequest -Endpoint "users/$UserId/password" -Method PUT -Body $body
    }
}
