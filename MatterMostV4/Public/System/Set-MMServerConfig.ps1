# Updates the MatterMost server configuration

function Set-MMServerConfig {
    <#
    .SYNOPSIS
        Updates the MatterMost server configuration.
    .DESCRIPTION
        Sends a PUT request to /config with the provided configuration object.
        Requires manage_system permission (admin only).
    .PARAMETER Config
        The full server configuration object to apply.
    .OUTPUTS
        PSCustomObject. The updated server configuration.
    .EXAMPLE
        $cfg = Get-MMServerConfig
        $cfg.ServiceSettings.SiteURL = 'https://new.example.com'
        Set-MMServerConfig -Config $cfg
    #>
    [OutputType('PSCustomObject')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [object]$Config
    )

    process {
        if ($PSCmdlet.ShouldProcess('MatterMost server', 'Update server configuration')) {
            Invoke-MMRequest -Endpoint 'config' -Method PUT -Body $Config
        }
    }
}
