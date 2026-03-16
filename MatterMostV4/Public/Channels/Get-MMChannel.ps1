# Получение канала MatterMost

function Get-MMChannel {
    <#
    .SYNOPSIS
        Возвращает канал MatterMost по ID, имени внутри команды, список каналов команды или все каналы системы.
    .EXAMPLE
        Get-MMChannel -All
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -TeamId 'team123' -Name 'general'
    .EXAMPLE
        Get-MMChannel -TeamId 'team123'
    #>
    [OutputType('MMChannel')]
    [CmdletBinding(DefaultParameterSetName = 'ByTeam')]
    param(
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ByTeam')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName', Position = 0)]
        [string]$Name
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'All' {
                $page    = 0
                $perPage = 200
                do {
                    $batch = Invoke-MMRequest -Endpoint "channels?page=$page&per_page=$perPage"
                    $batch | ConvertTo-MMChannel
                    $page++
                } while ($batch.Count -eq $perPage)
            }
            'ById'   { Invoke-MMRequest -Endpoint "channels/$ChannelId" | ConvertTo-MMChannel }
            'ByName' {
                $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }
                Invoke-MMRequest -Endpoint "teams/$resolvedTeamId/channels/name/$Name" | ConvertTo-MMChannel
            }
            'ByTeam' {
                $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }
                $page    = 0
                $perPage = 200
                do {
                    $batch = Invoke-MMRequest -Endpoint "teams/$resolvedTeamId/channels?page=$page&per_page=$perPage"
                    $batch | ConvertTo-MMChannel
                    $page++
                } while ($batch.Count -eq $perPage)
            }
        }
    }
}
