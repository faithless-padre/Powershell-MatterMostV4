# Удобная обёртка для отправки сообщений в личку, группу или канал

function Send-MMMessage {
    <#
    .SYNOPSIS
        Sends a message to a user (DM), group of users, or a channel by name.
    .EXAMPLE
        Send-MMMessage -ToUser 'john' -Message 'Hey!'
    .EXAMPLE
        Get-MMUser -Username 'john' | Send-MMMessage -Message 'Hey!'
    .EXAMPLE
        Send-MMMessage -ToUsers @('john', 'jane', 'bob') -Message 'Group message'
    .EXAMPLE
        Send-MMMessage -ToChannel 'general' -Message 'Hello everyone!'
    .EXAMPLE
        Send-MMMessage -ToChannel 'general' -Message 'With attachment' -FilePath 'C:\report.pdf'
    .EXAMPLE
        Send-MMMessage -ToChannel 'general' -Message 'Thread reply' -RootId $post.id
    #>
    [CmdletBinding(DefaultParameterSetName = 'ToUser')]
    [OutputType('MMPost')]
    param(
        # Отправить личное сообщение пользователю по username
        [Parameter(Mandatory, ParameterSetName = 'ToUser')]
        [string]$ToUser,

        # Отправить личное сообщение пользователю по ID (поддержка пайпа из MMUser)
        [Parameter(Mandatory, ParameterSetName = 'ToUserId', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ToUserId,

        # Отправить групповое сообщение нескольким пользователям по username (3–7 человек, текущий юзер добавляется автоматически)
        [Parameter(Mandatory, ParameterSetName = 'ToUsers')]
        [ValidateCount(2, 7)]
        [string[]]$ToUsers,

        # Отправить сообщение в канал по имени
        [Parameter(Mandatory, ParameterSetName = 'ToChannel')]
        [string]$ToChannel,

        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [Alias('ParentId')]
        [string]$RootId,

        [Parameter()]
        [ValidateCount(1, 5)]
        [string[]]$FilePath
    )

    process {
        $channelId = switch ($PSCmdlet.ParameterSetName) {

            'ToUser' {
                $target = Get-MMUser -Username $ToUser
                (New-MMDirectChannel -UserId1 $script:MMSession.UserId -UserId2 $target.id).id
            }

            'ToUserId' {
                (New-MMDirectChannel -UserId1 $script:MMSession.UserId -UserId2 $ToUserId).id
            }

            'ToUsers' {
                $targets = Get-MMUser -Usernames $ToUsers
                $ids = @($script:MMSession.UserId) + @($targets | Select-Object -ExpandProperty id)
                (New-MMGroupChannel -UserIds $ids).id
            }

            'ToChannel' {
                (Get-MMChannel -Name $ToChannel).id
            }
        }

        $params = @{ ChannelId = $channelId; Message = $Message }
        if ($RootId)   { $params['RootId']   = $RootId }
        if ($FilePath) { $params['FilePath'] = $FilePath }

        New-MMPost @params
    }
}
