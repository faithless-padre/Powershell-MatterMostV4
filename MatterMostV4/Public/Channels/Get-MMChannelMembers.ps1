# Получение списка участников канала MatterMost

function Get-MMChannelMembers {
    <#
    .SYNOPSIS
        Returns the list of members for a MatterMost channel.
    .EXAMPLE
        Get-MMChannelMembers -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannelMembers -ChannelName 'general'
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
