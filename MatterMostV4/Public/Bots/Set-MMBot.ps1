# Updates an existing bot account in MatterMost

function Set-MMBot {
    <#
    .SYNOPSIS
        Updates a MatterMost bot account (username, display name, description).
    .EXAMPLE
        Set-MMBot -BotUserId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMBot -BotUserId 'abc123' | Set-MMBot -Description 'Updated description'
    #>
    [CmdletBinding()]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('user_id')]
        [string]$BotUserId,

        [Parameter()]
        [string]$Username,

        [Parameter()]
        [string]$DisplayName,

        [Parameter()]
        [string]$Description
    )

    process {
        $body = @{}
        if ($Username)    { $body['username']     = $Username }
        if ($DisplayName) { $body['display_name'] = $DisplayName }
        if ($Description) { $body['description']  = $Description }

        Invoke-MMRequest -Endpoint "bots/$BotUserId" -Method PUT -Body $body | ConvertTo-MMBot
    }
}
