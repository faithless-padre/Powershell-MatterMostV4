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
        Remove-MMTeam -TeamId $script:TestTeam.id
    }
}

Describe 'Set-MMTeam' {

    Context 'Именованные параметры' {
        It 'обновляет DisplayName' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -DisplayName 'Updated Name'
            $result.display_name | Should -Be 'Updated Name'
        }

        It 'обновляет Description' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -Description 'New description'
            $result.description | Should -Be 'New description'
        }

        It 'обновляет CompanyName' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -CompanyName 'Acme Corp'
            $result.company_name | Should -Be 'Acme Corp'
        }

        It 'обновляет AllowOpenInvite' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -AllowOpenInvite $true
            $result.allow_open_invite | Should -Be $true
        }
    }

    Context 'Сырые данные через -Properties' {
        It 'обновляет поле через -Properties' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -Properties @{ description = 'RawDesc' }
            $result.description | Should -Be 'RawDesc'
        }

        It '-Properties перекрывает именованный параметр' {
            $result = Set-MMTeam -TeamId $script:TestTeam.id -DisplayName 'Named' -Properties @{ display_name = 'Override' }
            $result.display_name | Should -Be 'Override'
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
