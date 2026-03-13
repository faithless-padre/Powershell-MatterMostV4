# MatterMostV4

PowerShell module for managing MatterMost via REST API v4.

Compatible with **Windows PowerShell 5.x** and **PowerShell 7.x**.

## Installation

```powershell
Import-Module ./MatterMostV4/MatterMostV4.psd1
```

## Quick Start

```powershell
# Connect
Connect-MMServer -Url 'https://mattermost.example.com' -Username 'admin' -Password (Read-Host -AsSecureString)

# With default team (optional — lets you omit -TeamId in other commands)
Connect-MMServer -Url 'https://mattermost.example.com' -Username 'admin' -Password (Read-Host -AsSecureString) -DefaultTeam 'myteam'

# Disconnect
Disconnect-MMServer
```

## Commands

### Connection
| Command | Description |
|---|---|
| `Connect-MMServer` | Connect to MatterMost server |
| `Disconnect-MMServer` | Clear the current session |

### Users
| Command | Description |
|---|---|
| `Get-MMUser -All` | List all users |
| `Get-MMUser admin` | Get user by username (positional) |
| `Get-MMUser -UserId 'abc123'` | Get user by ID |
| `Get-MMUser -Me` | Get current user |
| `Get-MMUser -Filter { username -like 'adm*' }` | Filter users |
| `New-MMUser` | Create user |
| `Set-MMUser -UserId ... -Properties @{...}` | Update user profile (any fields) |
| `Set-MMUserPassword` | Change user password |
| `Set-MMUserRole` | Assign system role |
| `Enable-MMUser` | Re-activate deactivated user |
| `Remove-MMUser` | Delete user |

### Teams
| Command | Description |
|---|---|
| `Get-MMTeam -All` | List all teams |
| `Get-MMTeam myteam` | Get team by name (positional) |
| `Get-MMTeam -TeamId 'abc123'` | Get team by ID |
| `New-MMTeam` | Create team |
| `Set-MMTeam` | Update team |
| `Remove-MMTeam` | Delete team |
| `Get-MMUserTeams` | Get teams for a user |
| `Add-MMUserToTeam` | Add user to team |
| `Remove-MMUserFromTeam` | Remove user from team |

### Channels
| Command | Description |
|---|---|
| `Get-MMChannel -All` | List all channels (admin) |
| `Get-MMChannel` | List channels in default team |
| `Get-MMChannel general` | Get channel by name (positional) |
| `Get-MMChannel -ChannelId 'abc123'` | Get channel by ID |
| `New-MMChannel` | Create channel |
| `Set-MMChannel` | Update channel |
| `Remove-MMChannel` | Delete channel |
| `Get-MMUserChannels` | Get channels for a user |
| `Add-MMUserToChannel` | Add user to channel |
| `Remove-MMUserFromChannel` | Remove user from channel |

### Roles
| Command | Description |
|---|---|
| `Get-MMRole -All` | List all roles |
| `Get-MMRole system_admin` | Get role by name (positional) |
| `Get-MMRole -Names 'system_admin','team_admin'` | Get multiple roles |
| `Set-MMRole` | Update role permissions |

## Pipeline Support

Most commands support pipeline input:

```powershell
Get-MMUser -All | Where-Object { $_.roles -notlike '*admin*' } | Remove-MMUser -WhatIf

Get-MMUser admin | Set-MMUser -Properties @{ nickname = 'Boss' }

Get-MMUser -Filter { username -like 'test*' } | Add-MMUserToTeam -TeamId 'abc123'
```

## Development

### Requirements
- Docker + Docker Compose
- Make

### Run tests

```bash
cd Sandbox

make start       # start MatterMost
make tests       # run Pester integration tests
make stop        # tear down

# Test against multiple versions
make test-matrix
make test-matrix MM_VERSIONS="9.11.14 11.5.1"
```
