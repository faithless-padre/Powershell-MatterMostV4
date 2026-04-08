# Mattermost Powershell Module 

[![Integration Tests](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml/badge.svg)](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml)
[![coverage](https://img.shields.io/codecov/c/github/faithless-padre/Powershell-MatterMostV4?label=coverage)](https://codecov.io/gh/faithless-padre/Powershell-MatterMostV4)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/01d79e3dddeb4b29a2b2be7fb386317a)](https://app.codacy.com/gh/faithless-padre/Powershell-MatterMostV4/dashboard)

PowerShell module for managing MatterMost via REST API v4.
Compatible with **Windows PowerShell 5.x** and **PowerShell 7.x**.

For usage examples and full documentation, see the **[Wiki](https://github.com/faithless-padre/Powershell-MatterMostV4/wiki)**.
For module details and version history, check the **[PSGallery page](https://www.powershellgallery.com/packages/MatterMostV4)**.

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

Name                           Synopsis
----                           --------
Add-MMGroupMembers             Adds users to a MatterMost custom group.
Add-MMPostPin                  Pins a post to its MatterMost channel.
Add-MMPostReaction             Adds an emoji reaction to a MatterMost post.
Add-MMServerLogEntry           Writes a message to the MatterMost server log.
Add-MMUserToChannel            Adds a user to a MatterMost channel.
Add-MMUserToTeam               Adds a user to a MatterMost team.
Clear-MMServerCaches           Invalidates all in-memory caches on the MatterMost server.
Connect-MMServer               Connects to a MatterMost server and stores the session token for subsequent requests.
ConvertFrom-MMGuestUser        Promotes a guest user to a regular MatterMost user (POST /users/{id}/promote).
ConvertTo-MMBotAccount         Converts a MatterMost user account to a bot account.
ConvertTo-MMGuestUser          Demotes a regular user to a guest in MatterMost (POST /users/{id}/demote).
Disable-MMBot                  Disables a MatterMost bot account.
Disable-MMPlugin               Disables an active plugin on MatterMost.
Disable-MMUser                 Deactivates a MatterMost user (soft disable via PUT /active).
Disconnect-MMServer            Logs out from MatterMost and clears the stored session token.
Enable-MMBot                   Enables a disabled MatterMost bot account.
Enable-MMPlugin                Enables an installed plugin on MatterMost.
Enable-MMUser                  Activates a deactivated MatterMost user.
Find-MMEmoji                   Searches MatterMost custom emoji by name term or returns autocomplete suggestions.
Get-MMBot                      Gets a MatterMost bot by ID, returns a list of bots, or filters bots by expression.
Get-MMBulkPostReactions        Returns reactions for multiple MatterMost posts in a single request.
Get-MMChannel                  Returns a MatterMost channel by ID, name within a team, team channel list, or all channels.
Get-MMChannelMembers           Returns the list of members for a MatterMost channel.
Get-MMChannelPinnedPosts       Returns all pinned posts in a MatterMost channel.
Get-MMChannelPosts             Returns posts for a MatterMost channel with optional pagination and filtering.
Get-MMChannelStats             Returns statistics for a MatterMost channel.
Get-MMCommand                  Returns MatterMost slash commands by team or by command ID.
Get-MMEmoji                    Gets custom emoji by ID, name, list of names, or returns all custom emoji.
Get-MMFileLink                 Returns a public link to a MatterMost file that can be accessed without authentication.
Get-MMFileMetadata             Returns metadata for a previously uploaded MatterMost file.
Get-MMFilePreview              Downloads the preview image for a MatterMost file and saves it to the specified path.
Get-MMFileThumbnail            Downloads the thumbnail image for a MatterMost file and saves it to the specified path.
Get-MMFlaggedPosts             Returns posts flagged by the specified user.
Get-MMGroup                    Returns a MatterMost group by ID or lists groups with filtering.
Get-MMGroupMembers             Returns the list of users that are members of a MatterMost group.
Get-MMGroupStats               Returns statistics for a MatterMost group (group_id, total_member_count).
Get-MMIncomingWebhook          Gets incoming webhooks. Returns a single webhook by ID or a list filtered by team.
Get-MMJob                      Returns a MatterMost job by ID or lists all jobs.
Get-MMJobsByType               Returns MatterMost jobs of a specific type.
Get-MMLicenseInfo              Gets the client-facing license information from MatterMost.
Get-MMMessage                  Gets messages from a DM, group chat, channel by name, or by post ID(s).
Get-MMOAuthApp                 Returns OAuth apps registered in MatterMost. All apps or a specific app by ID.
Get-MMOutgoingWebhook          Gets outgoing webhooks. Returns a single webhook by ID or a list filtered by team or channel.
Get-MMPlugin                   Returns all installed plugins on the MatterMost server, split into active and inactive lists.
Get-MMPluginStatus             Returns the runtime status of all plugins across cluster nodes.
Get-MMPost                     Returns a MatterMost post by ID, or multiple posts by a list of IDs.
Get-MMPostFileInfo             Returns file metadata for all files attached to a MatterMost post.
Get-MMPostReactions            Returns all reactions made on a MatterMost post.
Get-MMPostThread               Returns all posts in a MatterMost thread (root post and all replies).
Get-MMPreference               Returns a single preference for a MatterMost user by category and name.
Get-MMPreferences              Returns all preferences for a MatterMost user.
Get-MMPreferencesByCategory    Returns preferences for a specific category for a MatterMost user.
Get-MMRole                     Returns a MatterMost role by ID, name, list of names, or all roles.
Get-MMScheduledPost            Returns scheduled posts for the current user in a team.
Get-MMServerAnalytics          Gets server analytics data from MatterMost (Enterprise).
Get-MMServerAudits             Gets server-wide audit log entries from MatterMost.
Get-MMServerConfig             Gets the full MatterMost server configuration.
Get-MMServerLogs               Gets server log entries from MatterMost.
Get-MMServerTimezones          Gets the list of supported IANA timezone names from the MatterMost server.
Get-MMSidebarCategories        Returns sidebar categories for a user in a team.
Get-MMSidebarCategory          Returns a single sidebar category by ID.
Get-MMSidebarCategoryOrder     Returns the ordered list of sidebar category IDs for a user in a team.
Get-MMTeam                     Returns a MatterMost team by ID, name, all teams, or filtered by expression.
Get-MMTeamIcon                 Downloads the team icon image and saves it to the specified file path.
Get-MMTeamInviteInfo           Returns public team information for a given invite ID.
Get-MMTeamMembers              Returns the list of members for a MatterMost team.
Get-MMTeamStats                Returns statistics for a MatterMost team (total and active member count).
Get-MMTeamUnreads              Returns unread message counts for teams for a given user.
Get-MMUser                     Returns a MatterMost user by ID, username, filter, or current session.
Get-MMUserAudit                Returns audit log entries for a MatterMost user (GET /users/{id}/audits).
Get-MMUserChannels             Returns the list of channels a user belongs to in a MatterMost team.
Get-MMUserProfileImage         Downloads the profile image of a MatterMost user to a local file.
Get-MMUsersByGroupChannel      Returns users for one or more group (GM) channels as a hashtable keyed by channel ID.
Get-MMUserSession              Returns the list of active sessions for a MatterMost user.
Get-MMUserStats                Returns overall MatterMost user statistics (total_users_count, total_bots_count).
Get-MMUserStatus               Gets the status of one or more MatterMost users.
Get-MMUserTeams                Returns the list of teams a MatterMost user belongs to.
Get-MMUserToken                Gets personal access tokens. Returns tokens for a user or a single token by ID.
Install-MMPlugin               Installs a plugin on MatterMost, either from a download URL or a local .tar.gz file.
Invoke-MMCommand               Executes a MatterMost slash command via the API (POST /commands/execute).
Invoke-MMDatabaseRecycle       Reconnects all MatterMost database connections.
Invoke-MMPostAction            Executes an interactive message button or menu action on a MatterMost post.
Move-MMChannel                 Moves a MatterMost channel to a different team.
Move-MMCommand                 Moves a MatterMost slash command to another team.
New-MMBot                      Creates a new bot account in MatterMost.
New-MMChannel                  Creates a new channel in a MatterMost team.
New-MMCommand                  Creates a new slash command in MatterMost (POST /commands).
New-MMDirectChannel            Creates a direct message (DM) channel between two MatterMost users.
New-MMEmoji                    Creates a new custom emoji in MatterMost from an image file.
New-MMEphemeralPost            Creates an ephemeral post visible only to the specified user.
New-MMGroup                    Creates a new custom group in MatterMost (Enterprise).
New-MMGroupChannel             Creates a group message channel for 3–8 MatterMost users.
New-MMIncomingWebhook          Creates a new incoming webhook for a MatterMost channel.
New-MMJob                      Creates a new background job in MatterMost of the specified type.
New-MMOAuthApp                 Registers a new OAuth application in MatterMost.
New-MMOutgoingWebhook          Creates a new outgoing webhook for a MatterMost team.
New-MMPost                     Creates a new post in a MatterMost channel.
New-MMPostReminder             Sets a reminder for the specified user about a MatterMost post.
New-MMScheduledPost            Creates a scheduled (delayed) post in a MatterMost channel.
New-MMSidebarCategory          Creates a new custom sidebar category for a user in a team.
New-MMTeam                     Creates a new team in MatterMost.
New-MMUser                     Creates a new user in MatterMost.
New-MMUserMFASecret            Generates a new MFA secret and QR code for a MatterMost user.
New-MMUserToken                Creates a personal access token for a MatterMost user.
Remove-MMChannel               Archives a MatterMost channel.
Remove-MMCommand               Deletes a MatterMost slash command.
Remove-MMEmoji                 Deletes a MatterMost custom emoji by ID.
Remove-MMGroup                 Deletes a MatterMost custom group by ID.
Remove-MMGroupMembers          Removes users from a MatterMost custom group.
Remove-MMIncomingWebhook       Deletes a MatterMost incoming webhook by ID.
Remove-MMOAuthApp              Deletes an OAuth application from MatterMost.
Remove-MMOutgoingWebhook       Deletes a MatterMost outgoing webhook by ID.
Remove-MMPlugin                Removes an installed plugin from MatterMost.
Remove-MMPost                  Deletes a MatterMost post.
Remove-MMPostAcknowledgement   Removes a user's acknowledgement from a MatterMost post.
Remove-MMPostPin               Unpins a post from its MatterMost channel.
Remove-MMPostReaction          Removes an emoji reaction from a MatterMost post.
Remove-MMPreferences           Deletes preferences for a MatterMost user.
Remove-MMScheduledPost         Deletes a scheduled post.
Remove-MMSidebarCategory       Deletes a custom sidebar category.
Remove-MMTeam                  Archives a MatterMost team.
Remove-MMTeamIcon              Removes the custom icon for a MatterMost team.
Remove-MMUser                  Deactivates a MatterMost user (soft delete).
Remove-MMUserCustomStatus      Clears a MatterMost user's custom status.
Remove-MMUserFromChannel       Removes a user from a MatterMost channel.
Remove-MMUserFromTeam          Removes a user from a MatterMost team.
Remove-MMUserProfileImage      Resets a MatterMost user's profile image to the auto-generated default.
Reset-MMCommandToken           Regenerates the token for a MatterMost slash command.
Reset-MMOAuthAppSecret         Regenerates the client secret for a MatterMost OAuth app.
Reset-MMOutgoingWebhookToken   Regenerates the security token for a MatterMost outgoing webhook.
Reset-MMTeamInvite             Regenerates the invite ID for a MatterMost team.
Restore-MMChannel              Restores a deleted (archived) MatterMost channel.
Restore-MMGroup                Restores a soft-deleted MatterMost group.
Restore-MMTeam                 Restores a deleted (archived) MatterMost team.
Revoke-MMAllUserSessions       Revokes all active sessions for a MatterMost user.
Revoke-MMUserSession           Revokes the specified MatterMost user session.
Revoke-MMUserToken             Revokes a MatterMost personal access token.
Save-MMEmojiImage              Downloads a MatterMost custom emoji image to the local filesystem.
Save-MMFile                    Downloads a file from MatterMost to the local filesystem.
Search-MMChannel               Searches MatterMost channels by term within a team.
Search-MMFile                  Searches for files in a MatterMost team by search terms.
Search-MMPost                  Searches for posts in a MatterMost team by text terms.
Search-MMUser                  Searches for MatterMost users by a search term.
Send-MMFile                    Uploads a file to a MatterMost channel. Returns an MMFile object with the file ID.
Send-MMMessage                 Sends a message to a user (DM), group of users, or a channel by name.
Send-MMPasswordResetEmail      Sends a password reset email to the specified user.
Send-MMTeamInvite              Sends an invitation to a MatterMost team by email address(es).
Set-MMBot                      Updates a MatterMost bot account (username, display name, description).
Set-MMBotOwner                 Assigns a MatterMost bot to a specified user.
Set-MMChannel                  Updates MatterMost channel settings (PUT /channels/{id}/patch).
Set-MMChannelMemberNotifyProps Updates notification preferences for a user in a MatterMost channel.
Set-MMChannelMemberRoles       Sets the roles of a user in a MatterMost channel.
Set-MMChannelPrivacy           Updates MatterMost channel privacy: Public or Private.
Set-MMChannelViewed            Marks a MatterMost channel as viewed for the current user.
Set-MMCommand                  Updates an existing MatterMost slash command.
Set-MMGroup                    Updates properties of a MatterMost custom group (patch).
Set-MMIncomingWebhook          Updates an existing MatterMost incoming webhook.
Set-MMOAuthApp                 Updates an existing OAuth application in MatterMost.
Set-MMOutgoingWebhook          Updates an existing MatterMost outgoing webhook.
Set-MMPost                     Updates the message of an existing MatterMost post (PATCH).
Set-MMPostAcknowledged         Acknowledges a MatterMost post that requires user acknowledgement.
Set-MMPostUnread               Marks a MatterMost post as unread for the specified user.
Set-MMPreferences              Creates or updates preferences for a MatterMost user.
Set-MMRole                     Updates the permissions list for the specified MatterMost role.
Set-MMScheduledPost            Updates a scheduled post's message or scheduled time.
Set-MMServerConfig             Updates the MatterMost server configuration.
Set-MMSidebarCategory          Updates an existing sidebar category.
Set-MMSidebarCategoryOrder     Sets the display order of sidebar categories for a user in a team.
Set-MMTeam                     Updates MatterMost team settings (PUT /teams/{id}/patch).
Set-MMTeamIcon                 Uploads an image file as the team icon.
Set-MMTeamMemberRoles          Sets the roles for a user in a MatterMost team.
Set-MMTeamPrivacy              Updates MatterMost team privacy: Open or Invite-only.
Set-MMUser                     Updates a MatterMost user profile (PUT /users/{id}/patch).
Set-MMUserCustomStatus         Sets a MatterMost user's custom status with an emoji, text, and optional duration.
Set-MMUserMFA                  Activates or deactivates MFA for a MatterMost user.
Set-MMUserPassword             Changes a MatterMost user password.
Set-MMUserProfileImage         Uploads a profile image for a MatterMost user.
Set-MMUserRole                 Assigns system roles to a MatterMost user.
Set-MMUserStatus               Sets a MatterMost user's status to online, away, dnd, or offline.
Stop-MMJob                     Cancels a running or pending MatterMost background job.
Test-MMEmail                   Sends a test email using the MatterMost server's SMTP configuration.
Test-MMServer                  Checks the health of the MatterMost server.
```

</details>

