BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = $fileConfig.TestTeamName
    }
    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)

    $script:Suffix   = (Get-Date -Format 'HHmmss')
    $script:TestPass = ConvertTo-SecureString 'Pester123!' -AsPlainText -Force
    $script:Team     = Get-MMTeam -Name $config.TestTeamName
    $script:TestUser = New-MMUser `
        -Username "tmtest_$($script:Suffix)" `
        -Email    "tmtest_$($script:Suffix)@test.local" `
        -Password $script:TestPass
}

AfterAll {
    if ($script:TestUser) {
        Remove-MMUser -UserId $script:TestUser.id
    }
}

Describe 'Add-MMUserToTeam' {

    Context 'Добавление пользователя' {
        It 'добавляет пользователя в команду' {
            { Add-MMUserToTeam -TeamId $script:Team.id -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'пользователь появляется в списке команд' {
            $teams = Get-MMUserTeams -UserId $script:TestUser.id
            $teams.id | Should -Contain $script:Team.id
        }

        It 'принимает объект пользователя из пайплайна' {
            $extraUser = New-MMUser -Username "tmadd_$($script:Suffix)" -Email "tmadd_$($script:Suffix)@test.local" -Password $script:TestPass
            try {
                { $extraUser | Add-MMUserToTeam -TeamId $script:Team.id } | Should -Not -Throw
            } finally {
                Remove-MMUser -UserId $extraUser.id
            }
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { Add-MMUserToTeam -TeamId 'invalid-id' -UserId $script:TestUser.id } | Should -Throw
        }
    }
}

Describe 'Remove-MMUserFromTeam' {

    Context 'Удаление пользователя' {
        BeforeAll {
            Add-MMUserToTeam -TeamId $script:Team.id -UserId $script:TestUser.id
        }

        It 'удаляет пользователя из команды' {
            { Remove-MMUserFromTeam -TeamId $script:Team.id -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'пользователя нет в списке команд после удаления' {
            $teams = Get-MMUserTeams -UserId $script:TestUser.id
            $teams.id | Should -Not -Contain $script:Team.id
        }

        It 'принимает объект пользователя из пайплайна' {
            Add-MMUserToTeam -TeamId $script:Team.id -UserId $script:TestUser.id
            { $script:TestUser | Remove-MMUserFromTeam -TeamId $script:Team.id } | Should -Not -Throw
        }
    }
}

Describe 'Get-MMUserTeams' {

    Context 'Список команд' {
        BeforeAll {
            Add-MMUserToTeam -TeamId $script:Team.id -UserId $script:TestUser.id
        }

        It 'возвращает команды пользователя' {
            $teams = Get-MMUserTeams -UserId $script:TestUser.id
            $teams | Should -Not -BeNullOrEmpty
            $teams.id | Should -Contain $script:Team.id
        }

        It 'принимает объект пользователя из пайплайна' {
            $teams = $script:TestUser | Get-MMUserTeams
            $teams.id | Should -Contain $script:Team.id
        }
    }
}
