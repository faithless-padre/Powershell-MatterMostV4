# Получение статистики пользователей MatterMost

function Get-MMUserStats {
    <#
    .SYNOPSIS
        Returns overall MatterMost user statistics (total_users_count, total_bots_count).
    .EXAMPLE
        Get-MMUserStats
    #>
    [CmdletBinding()]
    param()

    Invoke-MMRequest -Endpoint 'users/stats'
}
