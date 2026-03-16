# Получение списка участников канала MatterMost

function Get-MMChannelMembers {
    <#
    .SYNOPSIS
        Возвращает список участников канала MatterMost.
    .EXAMPLE
        Get-MMChannelMembers -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -Name 'general' | Get-MMChannelMembers
    #>
    [CmdletBinding()]
    [OutputType('MMChannelMember')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId
    )

    process {
        $page    = 0
        $perPage = 200
        do {
            $batch = Invoke-MMRequest -Endpoint "channels/$ChannelId/members?page=$page&per_page=$perPage"
            $batch | ConvertTo-MMChannelMember
            $page++
        } while ($batch.Count -eq $perPage)
    }
}
