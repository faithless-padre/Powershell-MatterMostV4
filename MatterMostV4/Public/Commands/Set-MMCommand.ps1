# Обновление slash-команды MatterMost

function Set-MMCommand {
    <#
    .SYNOPSIS
        Updates an existing MatterMost slash command (PUT /commands/{command_id}).
    .DESCRIPTION
        Updates one or more fields of a slash command. Only the parameters you provide are included in the request body.
    .PARAMETER CommandId
        The ID of the command to update. Accepts pipeline input by property name (id).
    .PARAMETER Trigger
        The new trigger word for the command.
    .PARAMETER URL
        The new callback URL.
    .PARAMETER Method
        The HTTP method: 'P' = POST, 'G' = GET.
    .PARAMETER DisplayName
        The new display name.
    .PARAMETER Description
        The new description.
    .PARAMETER AutoComplete
        Whether the command appears in autocomplete. Pass $true or $false explicitly.
    .PARAMETER AutoCompleteDesc
        The new autocomplete description.
    .PARAMETER AutoCompleteHint
        The new autocomplete hint.
    .PARAMETER Username
        The new username for the response.
    .PARAMETER IconUrl
        The new icon URL.
    .OUTPUTS
        PSCustomObject. The updated command object.
    .EXAMPLE
        Set-MMCommand -CommandId 'cmd456' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMCommand -CommandId 'cmd456' | Set-MMCommand -URL 'https://new.example.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$CommandId,

        # MM API requires team_id in the PUT body to match the command's current team
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('team_id')]
        [string]$TeamId,

        [string]$Trigger,
        [string]$URL,

        [ValidateSet('P', 'G')]
        [string]$Method,

        [string]$DisplayName,
        [string]$Description,
        [nullable[bool]]$AutoComplete,
        [string]$AutoCompleteDesc,
        [string]$AutoCompleteHint,
        [string]$Username,
        [string]$IconUrl
    )

    process {
        $paramMap = @{
            Trigger          = 'trigger'
            URL              = 'url'
            Method           = 'method'
            DisplayName      = 'display_name'
            Description      = 'description'
            AutoComplete     = 'auto_complete'
            AutoCompleteDesc = 'auto_complete_desc'
            AutoCompleteHint = 'auto_complete_hint'
            Username         = 'username'
            IconUrl          = 'icon_url'
        }

        # MM PUT /commands/{id} требует полный объект — берём текущее состояние и оверлаим
        $current = Invoke-MMRequest -Endpoint "commands/$CommandId"
        $body = @{
            id       = $CommandId
            team_id  = if ($PSBoundParameters.ContainsKey('TeamId')) { $TeamId } else { $current.team_id }
            trigger  = if ($PSBoundParameters.ContainsKey('Trigger')) { $Trigger } else { $current.trigger }
            url      = if ($PSBoundParameters.ContainsKey('URL')) { $URL } else { $current.url }
            method   = if ($PSBoundParameters.ContainsKey('Method')) { $Method } else { $current.method }
        }
        foreach ($param in $paramMap.Keys) {
            if ($param -notin @('Trigger', 'URL', 'Method') -and $PSBoundParameters.ContainsKey($param)) {
                $body[$paramMap[$param]] = $PSBoundParameters[$param]
            }
        }

        Invoke-MMRequest -Endpoint "commands/$CommandId" -Method PUT -Body $body
    }
}
