# Удобная обёртка для отправки сообщений в личку, группу или канал

function Send-MMMessage {
    <#
    .SYNOPSIS
        Sends a message to a user (DM), group of users, or a channel by name.
    .DESCRIPTION
        A high-level convenience wrapper around New-MMPost. Automatically resolves DM/group channels
        from usernames. Supports file attachments and thread replies. For lower-level control, use New-MMPost directly.
    .PARAMETER ToUser
        The username of the user to send a direct message to. Used with the ToUser parameter set.
    .PARAMETER ToUserId
        The user ID to send a direct message to. Used with the ToUserId parameter set. Accepts pipeline input by property name (id).
    .PARAMETER ToUsers
        Array of 2–7 usernames for a group message. The current session user is added automatically. Used with the ToUsers parameter set.
    .PARAMETER ToChannel
        The name of the channel to post to. Used with the ToChannel parameter set.
    .PARAMETER Message
        The message text. Supports MatterMost markdown.
    .PARAMETER RootId
        The ID of the root post to reply to (creates a thread reply).
    .PARAMETER FilePath
        One or more local file paths to upload and attach (maximum 5 files).
    .OUTPUTS
        MMPost. The newly created post object.
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
