# Получение статистики пользователей MatterMost

function Get-MMUserStats {
    <#
    .SYNOPSIS
        Возвращает общую статистику пользователей MatterMost (total_users_count, total_bots_count).
    .EXAMPLE
        Get-MMUserStats
    #>
    [CmdletBinding()]
    param()

    Invoke-MMRequest -Endpoint 'users/stats'
}
