# Получение статистики пользователей MatterMost

function Get-MMUserStats {
    <#
    .SYNOPSIS
        Returns overall MatterMost user statistics (total_users_count, total_bots_count).
    .DESCRIPTION
        Calls GET /users/stats to return server-wide user counts.
        The response includes total_users_count (all non-deleted users) and total_bots_count.
        Requires admin permissions.
    .OUTPUTS
        System.Object. Raw stats object with total_users_count and total_bots_count properties.
    .EXAMPLE
        Get-MMUserStats
    #>
    [CmdletBinding()]
    param()

    Invoke-MMRequest -Endpoint 'users/stats'
}
