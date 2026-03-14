# MatterMostV4

[![Integration Tests](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml/badge.svg)](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml)
[![coverage](https://img.shields.io/codecov/c/github/faithless-padre/Powershell-MatterMostV4?label=coverage)](https://codecov.io/gh/faithless-padre/Powershell-MatterMostV4)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/01d79e3dddeb4b29a2b2be7fb386317a)](https://app.codacy.com/gh/faithless-padre/Powershell-MatterMostV4/dashboard)

PowerShell module for managing MatterMost via REST API v4.
Compatible with **Windows PowerShell 5.x** and **PowerShell 7.x**.

---

## Prerequisites

| Tool | Minimum version |
|---|---|
| PowerShell | 5.1 |
| MatterMost Server | 9.x |

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

**Connect to a server:**

```powershell
# Basic
Connect-MMServer -Url 'https://mattermost.example.com' -Username 'admin' -Password (Read-Host -AsSecureString)

# With default team — lets you omit -TeamId in subsequent commands
Connect-MMServer -Url 'https://mattermost.example.com' -Username 'admin' -Password (Read-Host -AsSecureString) -DefaultTeam 'myteam'
```

---

## Available Commands

| Command | Synopsis |
|---|---|
| `Add-MMUserToChannel` | Adds a user to a MatterMost channel. |
| `Add-MMUserToTeam` | Adds a user to a MatterMost team. |
| `Connect-MMServer` | Connects to a MatterMost server and stores the session token. |
| `ConvertFrom-MMGuestUser` | Promotes a guest user to a regular user. |
| `ConvertTo-MMGuestUser` | Demotes a regular user to a guest user. |
| `Disable-MMUser` | Deactivates a MatterMost user. |
| `Disconnect-MMServer` | Ends the MatterMost session and clears the stored token. |
| `Enable-MMUser` | Activates a previously deactivated MatterMost user. |
| `Get-MMChannel` | Returns a channel by ID, name, team, or all channels. |
| `Get-MMRole` | Returns a role by ID, name, list of names, or all roles. |
| `Get-MMTeam` | Returns a team by ID, name, or all teams. |
| `Get-MMUser` | Returns a user by ID, username, email, filter, or current session. |
| `Get-MMUserAudit` | Returns audit records for a MatterMost user. |
| `Get-MMUserChannels` | Returns channels a user belongs to in a given team. |
| `Get-MMUserTeams` | Returns teams a user is a member of. |
| `New-MMChannel` | Creates a new channel in a MatterMost team. |
| `New-MMTeam` | Creates a new MatterMost team. |
| `New-MMUser` | Creates a new MatterMost user. |
| `Remove-MMChannel` | Archives a MatterMost channel. |
| `Remove-MMTeam` | Archives a MatterMost team. |
| `Remove-MMUser` | Deactivates a MatterMost user (soft delete). |
| `Remove-MMUserFromChannel` | Removes a user from a MatterMost channel. |
| `Remove-MMUserFromTeam` | Removes a user from a MatterMost team. |
| `Set-MMChannel` | Updates MatterMost channel properties. |
| `Set-MMRole` | Updates the permissions list for a MatterMost role. |
| `Set-MMTeam` | Updates MatterMost team properties. |
| `Set-MMUser` | Updates a MatterMost user profile. |
| `Set-MMUserPassword` | Changes a MatterMost user's password. |
| `Set-MMUserRole` | Assigns system roles to a MatterMost user. |
