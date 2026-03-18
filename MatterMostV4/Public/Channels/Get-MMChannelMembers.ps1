# Получение списка участников канала MatterMost

function Get-MMChannelMembers {
    <#
    .SYNOPSIS
        Returns the list of members for a MatterMost channel.
    .DESCRIPTION
        Retrieves all channel members from /channels/{channel_id}/members with automatic pagination (200 per page).
        Supports lookup by channel ID or channel name. When using -ChannelName, optionally provide -TeamId
        to disambiguate channels with the same name across teams.
    .PARAMETER ChannelId
        The ID of the channel. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER ChannelName
        The name (not display name) of the channel. Used with the ByName parameter set.
    .PARAMETER TeamId
        The team ID to scope the channel name lookup. Used with the ByName parameter set.
        Falls back to the default team set via Connect-MMServer -DefaultTeam if omitted.
    .OUTPUTS
        MMChannelMember. One or more channel membership objects.
    .EXAMPLE
        Get-MMChannelMembers -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannelMembers -ChannelName 'general'
    .EXAMPLE
        Get-MMChannelMembers -ChannelName 'general' -TeamId 'team123'
    .EXAMPLE
        Get-MMChannel -Name 'general' | Get-MMChannelMembers
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMChannelMember')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$ChannelName,

        [Parameter(ParameterSetName = 'ByName')]
        [string]$TeamId
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMChannel -Name $ChannelName -TeamId $TeamId).id
        } else {
            $ChannelId
        }

        $page    = 0
        $perPage = 200
        do {
            $batch = Invoke-MMRequest -Endpoint "channels/$resolvedId/members?page=$page&per_page=$perPage"
            $batch | ConvertTo-MMChannelMember
            $page++
        } while ($batch.Count -eq $perPage)
    }
}
