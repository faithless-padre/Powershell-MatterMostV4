@{
    ModuleVersion     = '0.1.0'
    GUID              = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author            = ''
    Description       = 'PowerShell wrapper for MatterMost REST API'
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
        'Get-MMUserTeams',
        'New-MMChannel',
        'New-MMTeam',
        'New-MMUser',
        'Remove-MMChannel',
        'Remove-MMTeam',
        'Remove-MMUser',
        'Remove-MMUserFromChannel',
        'Remove-MMUserFromTeam',
        'Set-MMChannel',
        'Set-MMRole',
        'Set-MMTeam',
        'Set-MMUser',
        'Set-MMUserPassword',
        'Set-MMUserRole'
    )
    FormatsToProcess  = @(
        'Formats/MatterMost.User.Format.ps1xml'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
