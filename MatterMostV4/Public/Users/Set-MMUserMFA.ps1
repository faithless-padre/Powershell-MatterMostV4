# Управление MFA (многофакторной аутентификацией) пользователя MatterMost

function Set-MMUserMFA {
    <#
    .SYNOPSIS
        Activates or deactivates MFA for a MatterMost user.
    .DESCRIPTION
        When -Activate is specified, enables TOTP-based MFA for the user. The -Code parameter
        (a valid TOTP code generated from the MFA secret) is required for activation.
        When -Activate is omitted, MFA is deactivated and -Code is not needed.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER UserId
        The ID of the user. Accepts pipeline input by property name (id).
    .PARAMETER Activate
        Switch. If present, activates MFA. If absent, deactivates MFA.
    .PARAMETER Code
        The TOTP code required when activating MFA. Must be non-empty when -Activate is specified.
    .OUTPUTS
        System.Void
    .EXAMPLE
        Set-MMUserMFA -UserId 'abc123' -Activate -Code '123456'
    .EXAMPLE
        Set-MMUserMFA -UserId 'abc123'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter()]
        [switch]$Activate,

        [Parameter()]
        [ValidateScript({
            if ($Activate -and [string]::IsNullOrWhiteSpace($_)) {
                throw '-Code must be non-empty when -Activate is specified.'
            }
            $true
        })]
        [string]$Code
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, "$(if ($Activate) { 'Activate' } else { 'Deactivate' }) MFA")) {
            $body = @{ activate = $Activate.IsPresent }
            if ($Activate) { $body['code'] = $Code }
            Invoke-MMRequest -Endpoint "users/$UserId/mfa" -Method PUT -Body $body | Out-Null
        }
    }
}
