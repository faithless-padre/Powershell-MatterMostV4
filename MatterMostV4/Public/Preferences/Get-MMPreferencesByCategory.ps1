# Получение предпочтений пользователя MatterMost по категории

function Get-MMPreferencesByCategory {
    <#
    .SYNOPSIS
        Returns preferences for a specific category for a MatterMost user (GET /users/{user_id}/preferences/{category}).
    .DESCRIPTION
        Fetches all preference objects belonging to the given category for the specified user.
    .PARAMETER UserId
        The user ID to fetch preferences for. Defaults to 'me'.
    .PARAMETER Category
        The preference category to filter by (e.g. 'display_settings', 'notifications').
    .OUTPUTS
        PSCustomObject. Array of preference objects in the specified category.
    .EXAMPLE
        Get-MMPreferencesByCategory -Category 'display_settings'
    .EXAMPLE
        Get-MMPreferencesByCategory -UserId 'abc123' -Category 'notifications'
    #>
    [CmdletBinding()]
    param(
        [string]$UserId = 'me',

        [Parameter(Mandatory)]
        [string]$Category
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/preferences/$Category"
    }
}
