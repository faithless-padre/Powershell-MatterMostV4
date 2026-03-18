# Sets a user's custom status in MatterMost

function Set-MMUserCustomStatus {
    <#
    .SYNOPSIS
        Sets a MatterMost user's custom status with an emoji, text, and optional duration.
    .DESCRIPTION
        Sends PUT /users/{user_id}/status/custom to set a custom status displayed next to the user's name.
        Use -Duration to auto-expire the status, or -ExpiresAt for a specific date/time (required when Duration is 'date_and_time').
    .PARAMETER UserId
        The ID of the user to update. Accepts pipeline input by property name (id, user_id).
    .PARAMETER Emoji
        The emoji shortcode (without colons) to display, e.g. 'calendar', 'house', 'bus'.
    .PARAMETER Text
        The custom status text to display, e.g. 'In a meeting', 'Working from home'.
    .PARAMETER Duration
        Optional auto-expiry duration. One of: 'thirty_minutes', 'one_hour', 'four_hours', 'today', 'this_week', 'date_and_time'.
    .PARAMETER ExpiresAt
        The exact expiry date and time. Required when Duration is 'date_and_time'. Converted to UTC internally.
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Set-MMUserCustomStatus -UserId 'abc123' -Emoji 'calendar' -Text 'In a meeting' -Duration 'one_hour'
    .EXAMPLE
        Get-MMUser -Username 'john' | Set-MMUserCustomStatus -Emoji 'house' -Text 'Working from home'
    .EXAMPLE
        Set-MMUserCustomStatus -UserId 'abc123' -Emoji 'bus' -Text 'Commuting' -Duration 'date_and_time' -ExpiresAt (Get-Date).AddHours(1)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id', 'user_id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$Emoji,

        [Parameter(Mandatory)]
        [string]$Text,

        [Parameter()]
        [ValidateSet('thirty_minutes', 'one_hour', 'four_hours', 'today', 'this_week', 'date_and_time')]
        [string]$Duration,

        # Required when Duration is 'date_and_time'. ISO 8601 format used internally.
        [Parameter()]
        [DateTime]$ExpiresAt
    )

    process {
        $body = @{
            emoji = $Emoji
            text  = $Text
        }
        if ($Duration) { $body['duration'] = $Duration }
        if ($PSBoundParameters.ContainsKey('ExpiresAt')) {
            $body['expires_at'] = $ExpiresAt.ToUniversalTime().ToString('o')
        }

        Invoke-MMRequest -Endpoint "users/$UserId/status/custom" -Method PUT -Body $body | Out-Null
    }
}
