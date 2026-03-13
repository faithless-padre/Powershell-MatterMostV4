# Смена пароля пользователя MatterMost

function Set-MMUserPassword {
    <#
    .SYNOPSIS
        Меняет пароль пользователя MatterMost.
    .EXAMPLE
        Set-MMUserPassword -UserId 'abc123' -NewPassword 'NewPass123!'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Set-MMUserPassword -NewPassword 'NewPass123!'
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
