# Получение канала MatterMost

function Get-MMChannel {
    <#
    .SYNOPSIS
        Возвращает канал MatterMost по ID, имени внутри команды или список каналов команды.
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123'
    .EXAMPLE
        Get-MMChannel -TeamId 'team123' -Name 'general'
    .EXAMPLE
        Get-MMChannel -TeamId 'team123'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByTeam')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [Parameter(Mandatory, ParameterSetName = 'ByTeam')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById'   { Invoke-MMRequest -Endpoint "channels/$ChannelId" }
            'ByName' { Invoke-MMRequest -Endpoint "teams/$TeamId/channels/name/$Name" }
            'ByTeam' {
                $page    = 0
                $perPage = 200
                do {
                    $batch = Invoke-MMRequest -Endpoint "teams/$TeamId/channels?page=$page&per_page=$perPage"
                    $batch
                    $page++
                } while ($batch.Count -eq $perPage)
            }
        }
    }
}
