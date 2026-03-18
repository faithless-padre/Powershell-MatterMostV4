# Завершение сессии MatterMost и очистка токена

function Disconnect-MMServer {
    <#
    .SYNOPSIS
        Logs out from MatterMost and clears the stored session token.
    .DESCRIPTION
        Sends POST /users/logout to invalidate the current session on the server,
        then clears the $script:MMSession variable. If the logout request fails, a warning is issued
        but the local session is still cleared.
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Disconnect-MMServer
    #>
    [CmdletBinding()]
    param()

    if (-not $script:MMSession) {
        Write-Warning "No active MatterMost session."
        return
    }

    try {
        Invoke-MMRequest -Endpoint 'users/logout' -Method POST
    }
    catch {
        Write-Warning "Logout request failed: $_"
    }
    finally {
        $script:MMSession = $null
        Write-Verbose "Disconnected from MatterMost."
    }
}
