# Отправка письма для сброса пароля пользователя MatterMost

function Send-MMPasswordResetEmail {
    <#
    .SYNOPSIS
        Sends a password reset email to the specified user.
    .DESCRIPTION
        Admin function. Triggers a password reset email for the given email address.
        The user will receive an email with a link to reset their password.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER Email
        The email address of the user to send the password reset link to.
    .OUTPUTS
        System.Void
    .EXAMPLE
        Send-MMPasswordResetEmail -Email 'user@example.com'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Email
    )

    process {
        if ($PSCmdlet.ShouldProcess($Email, 'Send password reset email')) {
            Invoke-MMRequest -Endpoint 'users/password/reset/send' -Method POST -Body @{ email = $Email } | Out-Null
        }
    }
}
