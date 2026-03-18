# Updates an existing bot account in MatterMost

function Set-MMBot {
    <#
    .SYNOPSIS
        Updates a MatterMost bot account (username, display name, description).
    .DESCRIPTION
        Sends a PUT request to /bots/{bot_user_id} to update one or more properties of the bot.
        Only the provided parameters are changed; omitted parameters retain their current values.
    .PARAMETER BotUserId
        The user ID of the bot to update. Accepts pipeline input by property name (user_id).
    .PARAMETER Username
        New username for the bot.
    .PARAMETER DisplayName
        New display name for the bot.
    .PARAMETER Description
        New description for the bot.
    .OUTPUTS
        MMBot. The updated bot object.
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
