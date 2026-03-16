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
<summary>Get-Command -Module MatterMostV4</summary>

```
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Add-MMUserToChannel                                0.1.0      MatterMostV4
Function        Add-MMUserToTeam                                   0.1.0      MatterMostV4
Function        Connect-MMServer                                   0.1.0      MatterMostV4
Function        ConvertFrom-MMGuestUser                            0.1.0      MatterMostV4
Function        ConvertTo-MMGuestUser                              0.1.0      MatterMostV4
Function        Disable-MMUser                                     0.1.0      MatterMostV4
Function        Disconnect-MMServer                                0.1.0      MatterMostV4
Function        Enable-MMUser                                      0.1.0      MatterMostV4
Function        Get-MMChannel                                      0.1.0      MatterMostV4
Function        Get-MMChannelMembers                               0.1.0      MatterMostV4
Function        Get-MMRole                                         0.1.0      MatterMostV4
Function        Get-MMTeam                                         0.1.0      MatterMostV4
Function        Get-MMTeamMembers                                  0.1.0      MatterMostV4
Function        Get-MMUser                                         0.1.0      MatterMostV4
Function        Get-MMUserAudit                                    0.1.0      MatterMostV4
Function        Get-MMUserChannels                                 0.1.0      MatterMostV4
Function        Get-MMUserSession                                  0.1.0      MatterMostV4
Function        Get-MMUserStats                                    0.1.0      MatterMostV4
Function        Get-MMUserTeams                                    0.1.0      MatterMostV4
Function        New-MMChannel                                      0.1.0      MatterMostV4
Function        New-MMDirectChannel                                0.1.0      MatterMostV4
Function        New-MMGroupChannel                                 0.1.0      MatterMostV4
Function        New-MMTeam                                         0.1.0      MatterMostV4
Function        New-MMUser                                         0.1.0      MatterMostV4
Function        Remove-MMChannel                                   0.1.0      MatterMostV4
Function        Remove-MMTeam                                      0.1.0      MatterMostV4
Function        Remove-MMUser                                      0.1.0      MatterMostV4
Function        Remove-MMUserFromChannel                           0.1.0      MatterMostV4
Function        Remove-MMUserFromTeam                              0.1.0      MatterMostV4
Function        Restore-MMChannel                                  0.1.0      MatterMostV4
Function        Restore-MMTeam                                     0.1.0      MatterMostV4
Function        Revoke-MMAllUserSessions                           0.1.0      MatterMostV4
Function        Revoke-MMUserSession                               0.1.0      MatterMostV4
Function        Send-MMTeamInvite                                  0.1.0      MatterMostV4
Function        Set-MMChannel                                      0.1.0      MatterMostV4
Function        Set-MMChannelPrivacy                               0.1.0      MatterMostV4
Function        Set-MMRole                                         0.1.0      MatterMostV4
Function        Set-MMTeam                                         0.1.0      MatterMostV4
Function        Set-MMTeamPrivacy                                  0.1.0      MatterMostV4
Function        Set-MMUser                                         0.1.0      MatterMostV4
Function        Set-MMUserPassword                                 0.1.0      MatterMostV4
Function        Set-MMUserRole                                     0.1.0      MatterMostV4
```

</details>
