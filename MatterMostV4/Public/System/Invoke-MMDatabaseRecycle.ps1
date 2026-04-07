# Reconnects all MatterMost database connections

function Invoke-MMDatabaseRecycle {
    <#
    .SYNOPSIS
        Reconnects all MatterMost database connections.
    .DESCRIPTION
        Sends a POST request to /database/recycle, which forces the server to
        close and reopen all database connections. Requires manage_system permission.
    .EXAMPLE
        Invoke-MMDatabaseRecycle
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    process {
        if ($PSCmdlet.ShouldProcess('MatterMost database', 'Recycle connections')) {
            Invoke-MMRequest -Endpoint 'database/recycle' -Method POST -Body @{} | Out-Null
        }
    }
}
