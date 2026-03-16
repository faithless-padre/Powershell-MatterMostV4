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
| PowerShell | 5.1 |
| MatterMost Server | 9.x |

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

```powershell
Get-Command -Module MatterMostV4
```
