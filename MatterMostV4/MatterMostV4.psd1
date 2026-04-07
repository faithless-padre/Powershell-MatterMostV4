@{
    ModuleVersion     = '1.0.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = 'Faithless Padre'
    CompanyName       = 'Ygdrassil Projects'
    Copyright         = '(c) 2025-2026 Ygdrassil Projects. All rights reserved.'
    Description       = 'PowerShell module for interacting with the MatterMost REST API. Supports user, channel, team, and role management.'
    PrivateData       = @{
        PSData = @{
            Tags       = @('MatterMost', 'Chat', 'REST', 'API', 'Messaging')
            ProjectUri = 'https://github.com/faithless-padre/Powershell-MatterMostV4'
            LicenseUri = 'https://github.com/faithless-padre/Powershell-MatterMostV4/blob/master/LICENSE'
        }
    }
    PowerShellVersion = '5.1'
    RootModule        = 'MatterMostV4.psm1'
    FunctionsToExport = @(
        'Add-MMUserToChannel',
        'Add-MMUserToTeam',
        'Connect-MMServer',
        'ConvertFrom-MMGuestUser',
        'ConvertTo-MMGuestUser',
        'Disable-MMUser',
        'Disconnect-MMServer',
        'Enable-MMUser',
        'Get-MMChannel',
        'Get-MMRole',
        'Get-MMTeam',
        'Get-MMUser',
        'Get-MMUserAudit',
        'Get-MMUserChannels',
        'Get-MMUserSession',
        'Get-MMUserStats',
        'Get-MMUserTeams',
        'Revoke-MMAllUserSessions',
        'Revoke-MMUserSession',
        'New-MMChannel',
        'New-MMTeam',
        'New-MMUser',
        'Remove-MMChannel',
        'Remove-MMTeam',
        'Remove-MMUser',
        'Remove-MMUserFromChannel',
        'Remove-MMUserFromTeam',
        'Get-MMChannelMembers',
        'New-MMDirectChannel',
        'New-MMGroupChannel',
        'Restore-MMChannel',
        'Set-MMChannel',
        'Set-MMChannelPrivacy',
        'Get-MMTeamMembers',
        'Restore-MMTeam',
        'Send-MMTeamInvite',
        'Set-MMChannelPrivacy',
        'Set-MMRole',
        'Set-MMTeam',
        'Set-MMTeamPrivacy',
        'Set-MMUser',
        'Set-MMUserPassword',
        'Set-MMUserRole',
        'Get-MMFileLink',
        'Get-MMFileMetadata',
        'Save-MMFile',
        'Send-MMFile',
        'Add-MMPostPin',
        'Get-MMChannelPosts',
        'Get-MMPost',
        'Get-MMPostThread',
        'New-MMPost',
        'Remove-MMPost',
        'Remove-MMPostPin',
        'Get-MMMessage',
        'Send-MMMessage',
        'Set-MMPost',
        'Get-MMIncomingWebhook',
        'New-MMIncomingWebhook',
        'Set-MMIncomingWebhook',
        'Remove-MMIncomingWebhook',
        'Get-MMOutgoingWebhook',
        'New-MMOutgoingWebhook',
        'Set-MMOutgoingWebhook',
        'Remove-MMOutgoingWebhook',
        'Reset-MMOutgoingWebhookToken',
        'Get-MMUserStatus',
        'Set-MMUserStatus',
        'Set-MMUserCustomStatus',
        'Remove-MMUserCustomStatus',
        'Disable-MMBot',
        'Enable-MMBot',
        'Get-MMBot',
        'New-MMBot',
        'Set-MMBot',
        'Set-MMBotOwner',
        'Get-MMUserToken',
        'New-MMUserToken',
        'Revoke-MMUserToken',
        'Find-MMEmoji',
        'Get-MMEmoji',
        'New-MMEmoji',
        'Remove-MMEmoji',
        'Save-MMEmojiImage',
        'Add-MMPostReaction',
        'Remove-MMPostReaction',
        'Get-MMPostReactions',
        'Get-MMBulkPostReactions',
        'New-MMScheduledPost',
        'Get-MMScheduledPost',
        'Set-MMScheduledPost',
        'Remove-MMScheduledPost'
    )
    FormatsToProcess  = @(
        'Formats/MatterMost.User.Format.ps1xml'
        'Formats/MatterMost.Channel.Format.ps1xml'
        'Formats/MatterMost.Team.Format.ps1xml'
        'Formats/MatterMost.Role.Format.ps1xml'
        'Formats/MatterMost.Session.Format.ps1xml'
        'Formats/MatterMost.ChannelMember.Format.ps1xml'
        'Formats/MatterMost.TeamMember.Format.ps1xml'
        'Formats/MatterMost.File.Format.ps1xml'
        'Formats/MatterMost.Post.Format.ps1xml'
        'Formats/MatterMost.IncomingWebhook.Format.ps1xml'
        'Formats/MatterMost.OutgoingWebhook.Format.ps1xml'
        'Formats/MatterMost.UserStatus.Format.ps1xml'
        'Formats/MatterMost.Emoji.Format.ps1xml'
        'Formats/MatterMost.UserToken.Format.ps1xml'
        'Formats/MatterMost.Bot.Format.ps1xml'
        'Formats/MatterMost.Reaction.Format.ps1xml'
        'Formats/MatterMost.ScheduledPost.Format.ps1xml'
    )
    TypesToProcess    = @(
        'MatterMost.Types.ps1xml'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
