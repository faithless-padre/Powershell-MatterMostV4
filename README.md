# Mattermost Powershell Module (ver. 0.1.0)

[![Integration Tests](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml/badge.svg)](https://github.com/faithless-padre/Powershell-MatterMostV4/actions/workflows/test.yml)
[![coverage](https://img.shields.io/codecov/c/github/faithless-padre/Powershell-MatterMostV4?label=coverage)](https://codecov.io/gh/faithless-padre/Powershell-MatterMostV4)

PowerShell module for managing MatterMost via REST API v4.

Compatible with **Windows PowerShell 5.x** and **PowerShell 7.x**.

---

## Project Structure

```
MatterMost/
├── MatterMostV4/               # Module code
│   ├── MatterMostV4.psd1       # Module manifest
│   ├── MatterMostV4.psm1       # Module loader
│   ├── Public/                 # Exported cmdlets (one file = one cmdlet)
│   │   ├── Channels/
│   │   ├── Connections/
│   │   ├── Roles/
│   │   ├── Teams/
│   │   └── Users/
│   └── Private/                # Internal helpers
├── Pester/
│   └── Integration/            # Integration tests (run against real MM)
└── Sandbox/                    # Docker environment for testing
    ├── docker-compose.yml
    ├── Makefile
    └── setup.sh                # Idempotent: creates admin, team, testuser
```

---

## Testing

Tests run inside Docker against a real MatterMost instance.
No mocks — all tests hit the actual API.

### Prerequisites

| Tool | Tested version |
|---|---|
| Docker | 29.2.1 |
| Docker Compose | 5.0.2 |
| GNU Make | 4.3 |
| Pester | 5.7.1 |

### MatterMost versions tested

| Version | Type |
|---|---|
| 9.11.14 | ESR |
| 10.11.4 | Regular |
| 11.5.1 | Latest |

### Running tests

```bash
cd Sandbox

make start        # start MatterMost + run setup (admin, team, testuser)
make tests        # run all Pester integration tests
make stop         # tear down containers and volumes

# Test against all configured MM versions sequentially
make test-matrix

# Test against specific versions
make test-matrix MM_VERSIONS="9.11.14 11.5.1"
```

`make stop` wipes all data — next `make start` is always a clean environment.

---

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

```powershell
PS> gcm -Module MatterMostV4 | Get-Help | Select-Object Name, @{N='Ver';E={(gcm $_.Name).Version}}, Synopsis | ft -a

Name                     Ver   Synopsis
----                     ---   --------
Add-MMUserToChannel      0.1.0 Добавляет пользователя в канал MatterMost.
Add-MMUserToTeam         0.1.0 Добавляет пользователя в команду MatterMost.
Connect-MMServer         0.1.0 Подключается к MatterMost серверу и сохраняет токен сессии для последующих запросов.
ConvertFrom-MMGuestUser  0.1.0 Повышает гостевого пользователя до обычного пользователя MatterMost.
ConvertTo-MMGuestUser    0.1.0 Понижает обычного пользователя до гостевого в MatterMost.
Disable-MMUser           0.1.0 Деактивирует пользователя MatterMost (soft disable через PUT /active).
Disconnect-MMServer      0.1.0 Завершает сессию MatterMost и очищает сохранённый токен.
Enable-MMUser            0.1.0 Активирует деактивированного пользователя MatterMost.
Get-MMChannel            0.1.0 Возвращает канал MatterMost по ID, имени внутри команды, список каналов команды или все каналы системы.
Get-MMRole               0.1.0 Возвращает роль MatterMost по ID, имени, списку имён или все роли сразу.
Get-MMTeam               0.1.0 Возвращает команду MatterMost по ID, имени или список всех команд.
Get-MMUser               0.1.0 Возвращает пользователя MatterMost по ID, username, email, фильтру или текущей сессии.
Get-MMUserAudit          0.1.0 Возвращает записи аудита пользователя MatterMost.
Get-MMUserChannels       0.1.0 Возвращает список каналов пользователя в указанной команде MatterMost.
Get-MMUserTeams          0.1.0 Возвращает список команд, в которых состоит пользователь MatterMost.
New-MMChannel            0.1.0 Создаёт новый канал в команде MatterMost.
New-MMTeam               0.1.0 Создаёт новую команду в MatterMost.
New-MMUser               0.1.0 Создаёт нового пользователя в MatterMost.
Remove-MMChannel         0.1.0 Архивирует канал MatterMost.
Remove-MMTeam            0.1.0 Архивирует команду MatterMost.
Remove-MMUser            0.1.0 Деактивирует пользователя MatterMost (soft delete).
Remove-MMUserFromChannel 0.1.0 Удаляет пользователя из канала MatterMost.
Remove-MMUserFromTeam    0.1.0 Удаляет пользователя из команды MatterMost.
Set-MMChannel            0.1.0 Обновляет параметры канала MatterMost.
Set-MMRole               0.1.0 Изменяет список permissions для указанной роли MatterMost.
Set-MMTeam               0.1.0 Обновляет параметры команды MatterMost.
Set-MMUser               0.1.0 Обновляет профиль пользователя MatterMost произвольными полями API.
Set-MMUserPassword       0.1.0 Меняет пароль пользователя MatterMost.
Set-MMUserRole           0.1.0 Назначает системные роли пользователю MatterMost.
```

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
