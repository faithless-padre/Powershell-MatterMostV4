# Sends a test email via the MatterMost server SMTP configuration

function Test-MMEmail {
    <#
    .SYNOPSIS
        Sends a test email using the MatterMost server's SMTP configuration.
    .DESCRIPTION
        Sends a POST request to /email/test to verify the SMTP settings are working.
        Requires manage_system permission.
    .EXAMPLE
        Test-MMEmail
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        if ($PSCmdlet.ShouldProcess('MatterMost server', 'Send test email')) {
            Invoke-MMRequest -Endpoint 'email/test' -Method POST -Body @{} | Out-Null
        }
    }
}
