# Sets a user's custom status in MatterMost

function Set-MMUserCustomStatus {
    <#
    .SYNOPSIS
        Sets a MatterMost user's custom status with an emoji, text, and optional duration.
    .EXAMPLE
        Set-MMUserCustomStatus -UserId 'abc123' -Emoji 'calendar' -Text 'In a meeting' -Duration 'one_hour'
    .EXAMPLE
        Get-MMUser -Username 'john' | Set-MMUserCustomStatus -Emoji 'house' -Text 'Working from home'
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
