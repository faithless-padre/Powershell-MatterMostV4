# Создание нового slash-командлета в MatterMost

function New-MMCommand {
    <#
    .SYNOPSIS
        Creates a new slash command in MatterMost (POST /commands).
    .DESCRIPTION
        Registers a new outgoing slash command for the specified team.
        The command will be triggered when users type the trigger word prefixed with '/'.
    .PARAMETER TeamId
        The ID of the team to create the command in.
    .PARAMETER Trigger
        The trigger word for the slash command (without the leading '/').
    .PARAMETER URL
        The URL that MatterMost will POST or GET when the command is triggered.
    .PARAMETER Method
        The HTTP method used to call the URL. 'P' = POST (default), 'G' = GET.
    .PARAMETER DisplayName
        The display name for the command shown in autocomplete.
    .PARAMETER Description
        A description of what the command does.
    .PARAMETER AutoComplete
        If set, the command appears in the autocomplete list.
    .PARAMETER AutoCompleteDesc
        The description shown in the autocomplete list.
    .PARAMETER AutoCompleteHint
        The hint shown in autocomplete (e.g. '[text]').
    .PARAMETER Username
        The username that posts the response.
    .PARAMETER IconUrl
        The URL of the icon to display for the command's response.
    .OUTPUTS
        PSCustomObject. The created command object.
    .EXAMPLE
        New-MMCommand -TeamId 'abc123' -Trigger 'hello' -URL 'https://example.com/hello'
    .EXAMPLE
        New-MMCommand -TeamId 'abc123' -Trigger 'greet' -URL 'https://example.com/greet' -Method 'G' -AutoComplete -AutoCompleteDesc 'Greet a user'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [string]$Trigger,

        [Parameter(Mandatory)]
        [string]$URL,

        [ValidateSet('P', 'G')]
        [string]$Method = 'P',

        [string]$DisplayName,
        [string]$Description,

        [switch]$AutoComplete,

        [string]$AutoCompleteDesc,
        [string]$AutoCompleteHint,
        [string]$Username,
        [string]$IconUrl
    )

    process {
        $body = @{
            team_id = $TeamId
            trigger = $Trigger
            url     = $URL
            method  = $Method
        }

        if ($PSBoundParameters.ContainsKey('DisplayName'))     { $body['display_name']      = $DisplayName }
        if ($PSBoundParameters.ContainsKey('Description'))     { $body['description']        = $Description }
        if ($PSBoundParameters.ContainsKey('AutoComplete'))    { $body['auto_complete']      = $AutoComplete.IsPresent }
        if ($PSBoundParameters.ContainsKey('AutoCompleteDesc')){ $body['auto_complete_desc'] = $AutoCompleteDesc }
        if ($PSBoundParameters.ContainsKey('AutoCompleteHint')){ $body['auto_complete_hint'] = $AutoCompleteHint }
        if ($PSBoundParameters.ContainsKey('Username'))        { $body['username']           = $Username }
        if ($PSBoundParameters.ContainsKey('IconUrl'))         { $body['icon_url']           = $IconUrl }

        Invoke-MMRequest -Endpoint 'commands' -Method POST -Body $body
    }
}
