BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }
    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

        Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
    $script:Suffix = (Get-Date -Format 'HHmmss')
}

Describe 'New-MMTeam' {

    Context 'Базовое создание' {
        BeforeAll {
            $script:NewTeam = New-MMTeam -Name "pteam$($script:Suffix)" -DisplayName "Pester Team $($script:Suffix)"
        }

        AfterAll {
            if ($script:NewTeam) {
                Remove-MMTeam -TeamId $script:NewTeam.id
            }
        }

        It 'возвращает объект команды' {
            $script:NewTeam      | Should -Not -BeNullOrEmpty
            $script:NewTeam.id   | Should -Not -BeNullOrEmpty
            $script:NewTeam.name | Should -Be "pteam$($script:Suffix)"
        }

        It 'команда доступна через Get-MMTeam' {
            $found = Get-MMTeam -Name "pteam$($script:Suffix)"
            $found.id | Should -Be $script:NewTeam.id
        }

        It 'по умолчанию создаётся открытая команда' {
            $script:NewTeam.type | Should -Be 'O'
        }
    }

    Context 'С параметрами' {
        BeforeAll {
            $script:InviteTeam = New-MMTeam -Name "invite$($script:Suffix)" -DisplayName 'Invite Team' -Type Invite -Description 'Test description'
        }

        AfterAll {
            if ($script:InviteTeam) {
                Remove-MMTeam -TeamId $script:InviteTeam.id
            }
        }

        It 'создаёт закрытую команду типа Invite' {
            $script:InviteTeam.type | Should -Be 'I'
        }

        It 'сохраняет Description' {
            $script:InviteTeam.description | Should -Be 'Test description'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при дублирующемся имени команды' {
            $tempTeam = New-MMTeam -Name "dup$($script:Suffix)" -DisplayName 'Dup Team'
            try {
                { New-MMTeam -Name "dup$($script:Suffix)" -DisplayName 'Dup Team 2' } | Should -Throw
            } finally {
                Remove-MMTeam -TeamId $tempTeam.id
            }
        }
    }
}
