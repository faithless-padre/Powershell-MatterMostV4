# Получение всех предпочтений пользователя MatterMost

function Get-MMPreferences {
    <#
    .SYNOPSIS
        Returns all preferences for a MatterMost user (GET /users/{user_id}/preferences).
    .DESCRIPTION
        Fetches the full list of preference objects for the specified user.
        Each preference object has: user_id, category, name, value.
    .PARAMETER UserId
        The user ID to fetch preferences for. Defaults to 'me' (currently authenticated user).
    .OUTPUTS
        PSCustomObject. Array of preference objects.
    .EXAMPLE
        Get-MMPreferences
    .EXAMPLE
        Get-MMPreferences -UserId 'abc123'
    #>
    [CmdletBinding()]
    param(
        [string]$UserId = 'me'
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/preferences"
    }
}
