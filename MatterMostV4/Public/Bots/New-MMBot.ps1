# Creates a new bot account in MatterMost

function New-MMBot {
    <#
    .SYNOPSIS
        Creates a new bot account in MatterMost.
    .DESCRIPTION
        Creates a bot user account via POST /bots. Requires the "Enable Bot Account Creation" system setting
        to be enabled in MatterMost. The created bot can be used with New-MMUserToken to generate access tokens
        for automation or integration scenarios.
    .PARAMETER Username
        The unique username for the bot. Must follow MatterMost username rules (lowercase, no spaces).
    .PARAMETER DisplayName
        The display name shown in MatterMost UI for the bot.
    .PARAMETER Description
        A short description of the bot's purpose.
    .OUTPUTS
        MMBot. The newly created bot object.
    .EXAMPLE
        New-MMBot -Username 'ci-bot' -DisplayName 'CI Notifier' -Description 'Posts build results'
    #>
    [CmdletBinding()]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory)]
        [string]$Username,

        [Parameter()]
        [string]$DisplayName,

        [Parameter()]
        [string]$Description
    )

    process {
        $body = @{ username = $Username }
        if ($DisplayName) { $body['display_name'] = $DisplayName }
        if ($Description) { $body['description']  = $Description }

        Invoke-MMRequest -Endpoint 'bots' -Method POST -Body $body | ConvertTo-MMBot
    }
}
