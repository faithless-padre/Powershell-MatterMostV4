# Завершение сессии MatterMost и очистка токена

function Disconnect-MMServer {
    <#
    .SYNOPSIS
        Завершает сессию MatterMost и очищает сохранённый токен.
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
