# Создание или обновление предпочтений пользователя MatterMost

function Set-MMPreferences {
    <#
    .SYNOPSIS
        Creates or updates preferences for a MatterMost user (PUT /users/{user_id}/preferences).
    .DESCRIPTION
        Saves an array of preference objects for the specified user.
        Each preference hashtable must include: user_id, category, name, value.
    .PARAMETER UserId
        The user ID whose preferences to update. Defaults to 'me'.
    .PARAMETER Preferences
        An array of hashtables, each with keys: user_id, category, name, value.
    .EXAMPLE
        Set-MMPreferences -Preferences @(@{ user_id = 'me'; category = 'display_settings'; name = 'theme'; value = 'dark' })
    .EXAMPLE
        Set-MMPreferences -UserId 'abc123' -Preferences $prefs
    #>
    [CmdletBinding()]
    param(
        [string]$UserId = 'me',

        [Parameter(Mandatory)]
        [hashtable[]]$Preferences
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/preferences" -Method PUT -Body $Preferences
    }
}
