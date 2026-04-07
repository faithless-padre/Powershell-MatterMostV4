# Invalidates all in-memory caches on the MatterMost server

function Clear-MMServerCaches {
    <#
    .SYNOPSIS
        Invalidates all in-memory caches on the MatterMost server.
    .DESCRIPTION
        Sends a POST request to /caches/invalidate, forcing the server to clear
        all cached data. Requires manage_system permission.
    .EXAMPLE
        Clear-MMServerCaches
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        if ($PSCmdlet.ShouldProcess('MatterMost server', 'Invalidate all caches')) {
            Invoke-MMRequest -Endpoint 'caches/invalidate' -Method POST -Body @{} | Out-Null
        }
    }
}
