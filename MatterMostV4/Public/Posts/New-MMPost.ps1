# Создаёт новый пост в канале MatterMost

function New-MMPost {
    <#
    .SYNOPSIS
        Creates a new post in a MatterMost channel.
    .EXAMPLE
        New-MMPost -ChannelId 'abc123' -Message 'Hello!'
    .EXAMPLE
        New-MMPost -ChannelName 'general' -Message 'Hello!'
    .EXAMPLE
        Get-MMChannel -Name 'general' | New-MMPost -Message 'Hello!'
    .EXAMPLE
        $root = New-MMPost -ChannelName 'general' -Message 'Root post'
        New-MMPost -ChannelName 'general' -Message 'Reply in thread' -RootId $root.id
    .EXAMPLE
        New-MMPost -ChannelName 'general' -Message 'With file' -FilePath 'C:\report.pdf'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id', 'channel_id')]
        [string]$ChannelId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$ChannelName,

        [Parameter(Mandatory)]
        [string]$Message,

        # ID корневого поста для ответа в тред. Передаётся явно: -RootId $post.id
        [Parameter()]
        [Alias('ParentId')]
        [string]$RootId,

        # Пути к файлам для прикрепления (до 5 штук)
        [Parameter()]
        [ValidateCount(1, 5)]
        [string[]]$FilePath
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $ChannelId = (Get-MMChannel -Name $ChannelName).id
        }

        $fileIds = @()
        if ($FilePath) {
            foreach ($path in $FilePath) {
                $uploaded = Send-MMFile -FilePath $path -ChannelId $ChannelId
                $fileIds += $uploaded.id
            }
        }

        $body = @{ channel_id = $ChannelId; message = $Message }
        if ($RootId)        { $body['root_id']  = $RootId }
        if ($fileIds.Count) { $body['file_ids'] = $fileIds }

        Invoke-MMRequest -Endpoint 'posts' -Method POST -Body $body | ConvertTo-MMPost
    }
}
