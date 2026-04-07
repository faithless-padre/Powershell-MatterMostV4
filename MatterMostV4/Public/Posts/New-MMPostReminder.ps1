# Устанавливает напоминание о посте MatterMost для пользователя

function New-MMPostReminder {
    <#
    .SYNOPSIS
        Sets a reminder for the specified user about a MatterMost post.
    .DESCRIPTION
        Calls POST /users/{user_id}/posts/{post_id}/reminder with a Unix millisecond
        timestamp so the user receives a reminder notification at the specified time.
        Defaults to the current authenticated user.
    .PARAMETER PostId
        The ID of the post to set a reminder for. Accepts pipeline input by property name (id).
    .PARAMETER RemindAt
        The datetime at which the reminder should fire.
    .PARAMETER UserId
        The user for whom the reminder is created. Defaults to the current authenticated user.
    .OUTPUTS
        System.Void.
    .EXAMPLE
        New-MMPostReminder -PostId 'abc123' -RemindAt (Get-Date).AddDays(1)
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | New-MMPostReminder -RemindAt (Get-Date).AddHours(2)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter(Mandatory)]
        [datetime]$RemindAt,

        [Parameter()]
        [string]$UserId
    )

    process {
        if (-not $UserId) {
            $UserId = (Invoke-MMRequest -Endpoint 'users/me').id
        }

        $targetTimeMs = [System.DateTimeOffset]::new($RemindAt).ToUnixTimeMilliseconds()

        Invoke-MMRequest -Endpoint "users/$UserId/posts/$PostId/reminder" -Method POST -Body @{
            target_time = $targetTimeMs
        } | Out-Null
    }
}
