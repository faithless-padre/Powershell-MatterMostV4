# Generates examples with output for Webhooks wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

$team    = Get-MMTeam -Name $MM_TEAM
$channel = Get-MMChannel -Name 'town-square' -TeamId $team.Id

# New-MMIncomingWebhook
$inHook = New-MMIncomingWebhook -ChannelId $channel.Id -DisplayName 'Demo Incoming Hook' -Description 'Created by wiki generator'
$ex += block "New-MMIncomingWebhook -ChannelId `$channel.Id -DisplayName 'Monitoring Alerts'" (fmtl $inHook)

# Get-MMIncomingWebhook
$inHooks = Get-MMIncomingWebhook -TeamId $team.Id
$ex += block "Get-MMIncomingWebhook -TeamId `$team.Id" (fmtt $inHooks)

# Set-MMIncomingWebhook
$updated = Set-MMIncomingWebhook -HookId $inHook.Id -ChannelId $channel.Id -DisplayName 'Updated Hook' -Description 'Updated by wiki generator'
$ex += block "Set-MMIncomingWebhook -HookId `$hook.Id -DisplayName 'Updated Hook'" (fmtl $updated)

# New-MMOutgoingWebhook
$outHook = New-MMOutgoingWebhook `
    -TeamId $team.Id `
    -DisplayName 'Demo Outgoing Hook' `
    -Description 'Created by wiki generator' `
    -TriggerWords @('!deploy') `
    -CallbackUrls @('https://ci.example.com/hook') `
    -ChannelId $channel.Id
$ex += block "New-MMOutgoingWebhook -TeamId `$team.Id -DisplayName 'Deploy Hook' -TriggerWords '!deploy' -CallbackUrls 'https://ci.example.com/hook'" (fmtl $outHook)

# Get-MMOutgoingWebhook
$outHooks = Get-MMOutgoingWebhook -TeamId $team.Id
$ex += block "Get-MMOutgoingWebhook -TeamId `$team.Id" (fmtt $outHooks)

# Reset token
$reset = Reset-MMOutgoingWebhookToken -HookId $outHook.Id
$ex += block "Reset-MMOutgoingWebhookToken -HookId `$hook.Id" (fmtl $reset)

# Remove webhooks
Remove-MMIncomingWebhook -HookId $inHook.Id | Out-Null
Remove-MMOutgoingWebhook -HookId $outHook.Id | Out-Null

$ex += block "Get-MMIncomingWebhook -TeamId `$team.Id | Remove-MMIncomingWebhook" 'status : OK'

Update-WikiPage '11.-Webhooks.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
