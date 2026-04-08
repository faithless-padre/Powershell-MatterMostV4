# Получение одного предпочтения пользователя MatterMost по категории и имени

function Get-MMPreference {
    <#
    .SYNOPSIS
        Returns a single preference for a MatterMost user (GET /users/{user_id}/preferences/{category}/name/{preference_name}).
    .DESCRIPTION
        Fetches a specific preference identified by category and name for the given user.
    .PARAMETER UserId
        The user ID to fetch the preference for. Defaults to 'me'.
    .PARAMETER Category
        The preference category (e.g. 'display_settings').
    .PARAMETER Name
        The preference name within the category (e.g. 'theme').
    .OUTPUTS
        PSCustomObject. A single preference object.
    .EXAMPLE
        Get-MMPreference -Category 'display_settings' -Name 'theme'
    .EXAMPLE
        Get-MMPreference -UserId 'abc123' -Category 'notifications' -Name 'email'
    #>
    [CmdletBinding()]
    param(
        [string]$UserId = 'me',

        [Parameter(Mandatory)]
        [string]$Category,

        [Parameter(Mandatory)]
        [string]$Name
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/preferences/$Category/name/$Name"
    }
}
