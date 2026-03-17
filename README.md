# Mattermost Powershell Module 

[![Integration Tests](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml/badge.svg)](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml)
[![coverage](https://img.shields.io/codecov/c/github/faithless-padre/Powershell-MatterMostV4?label=coverage)](https://codecov.io/gh/faithless-padre/Powershell-MatterMostV4)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/01d79e3dddeb4b29a2b2be7fb386317a)](https://app.codacy.com/gh/faithless-padre/Powershell-MatterMostV4/dashboard)

PowerShell module for managing MatterMost via REST API v4.
Compatible with **Windows PowerShell 5.x** and **PowerShell 7.x**.

---

## Prerequisites

| Tool | Minimum version |
|---|---|
| PowerShell | 5.1 - 7.0+ |
| MatterMost Server | 9.x - 11.x |

Integration tested against MatterMost **9.11.14 (ESR)**, **10.11.4**, **11.5.1**.

---

## Installation

**From PSGallery:**

```powershell
Install-Module MatterMostV4
```

**From source:**

```powershell
Import-Module ./MatterMostV4/MatterMostV4.psd1
```

---

## Available Commands

<details>
<summary><strong>Click to expand the full command list</strong></summary>

```
PS /home/padre/> Get-Command -Module MatterMostV4 | Get-Help | Select-Object Name, Synopsis     

Name                     Synopsis
----                     --------
Add-MMPostPin            Pins a post to its MatterMost channel.
Add-MMUserToChannel      Adds a user to a MatterMost channel.
Add-MMUserToTeam         Adds a user to a MatterMost team.
Connect-MMServer         Connects to a MatterMost server and stores the session token for subsequent requests.
ConvertFrom-MMGuestUser  Promotes a guest user to a regular MatterMost user (POST /users/{id}/promote).
ConvertTo-MMGuestUser    Demotes a regular user to a guest in MatterMost (POST /users/{id}/demote).
Disable-MMUser           Deactivates a MatterMost user (soft disable via PUT /active).
Disconnect-MMServer      Logs out from MatterMost and clears the stored session token.
Enable-MMUser            Activates a deactivated MatterMost user.
Get-MMChannel            Returns a MatterMost channel by ID, name within a team, team channel list, or all channels.
Get-MMChannelMembers     Returns the list of members for a MatterMost channel.
Get-MMChannelPosts       Returns posts for a MatterMost channel with optional pagination and filtering.
Get-MMMessage            Gets messages from a DM, group chat, channel by name, or by post ID(s).
Get-MMFileLink           Returns a public link to a MatterMost file that can be accessed without authentication.
Get-MMFileMetadata       Returns metadata for a previously uploaded MatterMost file.
Get-MMPost               Returns a MatterMost post by ID, or multiple posts by a list of IDs.
Get-MMPostThread         Returns all posts in a MatterMost thread (root post and all replies).
Find-MMEmoji             Searches MatterMost custom emoji by name term or returns autocomplete suggestions.
Get-MMEmoji              Gets custom emoji by ID, name, list of names, or returns all custom emoji.
Get-MMIncomingWebhook    Gets incoming webhooks. Returns a single webhook by ID or a list filtered by team.
Get-MMOutgoingWebhook    Gets outgoing webhooks. Returns a single webhook by ID or a list filtered by team or channel.
Get-MMRole               Returns a MatterMost role by ID, name, list of names, or all roles.
Get-MMTeam               Returns a MatterMost team by ID, name, or all teams.
Get-MMTeamMembers        Returns the list of members for a MatterMost team.
Get-MMUser               Returns a MatterMost user by ID, username, filter, or current session.
Get-MMUserAudit          Returns audit log entries for a MatterMost user (GET /users/{id}/audits).
Get-MMUserStatus         Gets the status of one or more MatterMost users.
Get-MMUserChannels       Returns the list of channels a user belongs to in a MatterMost team.
Get-MMUserSession        Returns the list of active sessions for a MatterMost user.
Get-MMUserStats          Returns overall MatterMost user statistics (total_users_count, total_bots_count).
Get-MMUserTeams          Returns the list of teams a MatterMost user belongs to.
New-MMChannel            Creates a new channel in a MatterMost team.
New-MMEmoji              Creates a new custom emoji in MatterMost from an image file.
New-MMIncomingWebhook    Creates a new incoming webhook for a MatterMost channel.
New-MMOutgoingWebhook    Creates a new outgoing webhook for a MatterMost team.
New-MMPost               Creates a new post in a MatterMost channel.
New-MMDirectChannel      Creates a direct message (DM) channel between two MatterMost users.
New-MMGroupChannel       Creates a group message channel for 3–8 MatterMost users.
New-MMTeam               Creates a new team in MatterMost.
New-MMUser               Creates a new user in MatterMost.
Remove-MMChannel         Archives a MatterMost channel.
Remove-MMEmoji           Deletes a MatterMost custom emoji by ID.
Remove-MMUserCustomStatus Clears a MatterMost user's custom status.
Remove-MMIncomingWebhook Deletes a MatterMost incoming webhook by ID.
Remove-MMOutgoingWebhook Deletes a MatterMost outgoing webhook by ID.
Remove-MMPost            Deletes a MatterMost post.
Remove-MMPostPin         Unpins a post from its MatterMost channel.
Remove-MMTeam            Archives a MatterMost team.
Remove-MMUser            Deactivates a MatterMost user (soft delete).
Remove-MMUserFromChannel Removes a user from a MatterMost channel.
Remove-MMUserFromTeam    Removes a user from a MatterMost team.
Reset-MMOutgoingWebhookToken Regenerates the security token for a MatterMost outgoing webhook.
Restore-MMChannel        Restores a deleted (archived) MatterMost channel.
Restore-MMTeam           Restores a deleted (archived) MatterMost team.
Revoke-MMAllUserSessions Revokes all active sessions for a MatterMost user.
Revoke-MMUserSession     Revokes the specified MatterMost user session.
Save-MMEmojiImage        Downloads a MatterMost custom emoji image to the local filesystem.
Save-MMFile              Downloads a file from MatterMost to the local filesystem.
Send-MMFile              Uploads a file to a MatterMost channel. Returns an MMFile object with the file ID.
Send-MMMessage           Sends a message to a user (DM), group of users, or a channel by name.
Send-MMTeamInvite        Sends an invitation to a MatterMost team by email address(es).
Set-MMChannel            Updates MatterMost channel settings (PUT /channels/{id}/patch).
Set-MMUserCustomStatus   Sets a MatterMost user's custom status with an emoji, text, and optional duration.
Set-MMUserStatus         Sets a MatterMost user's status to online, away, dnd, or offline.
Set-MMIncomingWebhook    Updates an existing MatterMost incoming webhook.
Set-MMOutgoingWebhook    Updates an existing MatterMost outgoing webhook.
Set-MMPost               Updates the message of an existing MatterMost post (PATCH).
Set-MMChannelPrivacy     Updates MatterMost channel privacy: Public or Private.
Set-MMRole               Updates the permissions list for the specified MatterMost role.
Set-MMTeam               Updates MatterMost team settings (PUT /teams/{id}/patch).
Set-MMTeamPrivacy        Updates MatterMost team privacy: Open or Invite-only.
Set-MMUser               Updates a MatterMost user profile (PUT /users/{id}/patch).
Set-MMUserPassword       Changes a MatterMost user password.
Set-MMUserRole           Assigns system roles to a MatterMost user.
```

</details>
