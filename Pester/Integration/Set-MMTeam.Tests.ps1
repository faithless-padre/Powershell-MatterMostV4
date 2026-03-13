BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }
    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
    $script:Suffix   = (Get-Date -Format 'HHmmss')
    $script:TestTeam = New-MMTeam -Name "setteam$($script:Suffix)" -DisplayName 'Set Test Team'
}

AfterAll {
    if ($script:TestTeam) {
        Invoke-MMRequest -Endpoint "teams/$($script:TestTeam.id)" -Method DELETE | Out-Null
    }
}

Describe 'Set-MMTeam' {

    Context 'Обновление полей' {
        It 'обновляет DisplayName' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -DisplayName 'Updated Name'
            $result.display_name | Should -Be 'Updated Name'
        }

        It 'обновляет Description' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -Description 'New description'
            $result.description | Should -Be 'New description'
        }

        It 'сохраняет остальные поля при частичном обновлении' {
            Set-MMTeam -TeamId $script:TestTeam.id -DisplayName 'Partial Update' | Out-Null
            $team = Get-MMTeam -TeamId $script:TestTeam.id
            $team.display_name | Should -Be 'Partial Update'
            $team.name         | Should -Be "setteam$($script:Suffix)"
        }
    }

    Context 'Pipeline' {
        It 'принимает объект команды из пайплайна' {
            $result = Get-MMTeam -TeamId $script:TestTeam.id | Set-MMTeam -DisplayName 'Pipeline Update'
            $result.display_name | Should -Be 'Pipeline Update'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { Set-MMTeam -TeamId 'invalid-id-xyz' -DisplayName 'Test' } | Should -Throw
        }
    }
}

Describe 'Remove-MMTeam' {

    Context 'Архивирование' {
        It 'архивирует команду без ошибок' {
            $team = New-MMTeam -Name "rmteam$($script:Suffix)" -DisplayName 'Remove Test'
            { Remove-MMTeam -TeamId $team.id } | Should -Not -Throw
        }

        It 'принимает объект команды из пайплайна' {
            $team = New-MMTeam -Name "rmpipe$($script:Suffix)" -DisplayName 'Remove Pipe'
            { $team | Remove-MMTeam } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { Remove-MMTeam -TeamId 'invalid-id-xyz' } | Should -Throw
        }
    }
}
