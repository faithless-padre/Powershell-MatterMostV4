# Удаление предпочтений пользователя MatterMost

function Remove-MMPreferences {
    <#
    .SYNOPSIS
        Deletes preferences for a MatterMost user (DELETE /users/{user_id}/preferences).
    .DESCRIPTION
        Removes one or more preferences for the specified user.
        Each preference hashtable must include: user_id, category, name, value.
    .PARAMETER UserId
        The user ID whose preferences to delete. Defaults to 'me'.
    .PARAMETER Preferences
        An array of hashtables identifying the preferences to remove.
    .EXAMPLE
        Remove-MMPreferences -Preferences @(@{ user_id = 'me'; category = 'display_settings'; name = 'theme'; value = 'dark' })
    .EXAMPLE
        Remove-MMPreferences -UserId 'abc123' -Preferences $prefs
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$UserId = 'me',

        [Parameter(Mandatory)]
        [hashtable[]]$Preferences
    )

    process {
        if ($PSCmdlet.ShouldProcess("user '$UserId'", 'Remove preferences')) {
            Invoke-MMRequest -Endpoint "users/$UserId/preferences/delete" -Method POST -Body $Preferences
        }
    }
}
