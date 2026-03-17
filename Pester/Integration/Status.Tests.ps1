BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestUsername  = if ($env:MM_TEST_USERNAME)  { $env:MM_TEST_USERNAME }  else { $fileConfig.TestUsername }
        TestTeamName  = if ($env:MM_TEST_TEAM_NAME) { $env:MM_TEST_TEAM_NAME } else { $fileConfig.TestTeamName }
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force) -DefaultTeam $config.TestTeamName

    $script:AdminUser = Get-MMUser -Username $config.AdminUsername
    $script:TestUser  = Get-MMUser -Username $config.TestUsername
}

Describe 'Get-MMUserStatus' {

    Context 'Получение статуса по UserId' {
        It 'возвращает статус и объект MMUserStatus' {
            $result = Get-MMUserStatus -UserId $script:AdminUser.id

            $result                | Should -Not -BeNullOrEmpty
            $result.user_id        | Should -Be $script:AdminUser.id
            $result.status         | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'MMUserStatus'
        }

        It 'принимает объект MMUser из пайплайна' {
            $result = $script:AdminUser | Get-MMUserStatus

            $result.user_id | Should -Be $script:AdminUser.id
        }
    }

    Context 'Batch получение статусов по UserIds' {
        It 'возвращает статусы нескольких пользователей' {
            $result = Get-MMUserStatus -UserIds @($script:AdminUser.id, $script:TestUser.id)

            $result       | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $result[0].GetType().Name | Should -Be 'MMUserStatus'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Get-MMUserStatus -UserId 'invalid-user-id' } | Should -Throw
        }
    }
}

Describe 'Set-MMUserStatus' {

    Context 'Установка статуса' {
        It 'устанавливает статус away' {
            $result = Set-MMUserStatus -UserId $script:AdminUser.id -Status 'away'

            $result.user_id        | Should -Be $script:AdminUser.id
            $result.status         | Should -Be 'away'
            $result.GetType().Name | Should -Be 'MMUserStatus'
        }

        It 'устанавливает статус online' {
            $result = Set-MMUserStatus -UserId $script:AdminUser.id -Status 'online'

            $result.status | Should -Be 'online'
        }

        It 'устанавливает dnd с DndEndTime' {
            $endTime = (Get-Date).AddHours(1)
            $result  = Set-MMUserStatus -UserId $script:AdminUser.id -Status 'dnd' -DndEndTime $endTime

            $result.status | Should -Be 'dnd'
        }

        It 'принимает объект MMUser из пайплайна' {
            $result = $script:AdminUser | Set-MMUserStatus -Status 'online'

            $result.user_id | Should -Be $script:AdminUser.id
            $result.status  | Should -Be 'online'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Set-MMUserStatus -UserId 'invalid-id' -Status 'online' } | Should -Throw
        }
    }
}

Describe 'Set-MMUserCustomStatus / Remove-MMUserCustomStatus' {

    Context 'Установка кастомного статуса' {
        It 'устанавливает кастомный статус без ошибок' {
            { Set-MMUserCustomStatus -UserId $script:AdminUser.id -Emoji 'calendar' -Text 'In a meeting' } |
                Should -Not -Throw
        }

        It 'устанавливает кастомный статус с duration' -Skip {
            # Duration поддерживается только в MM >= 7.7 с включённым EnableCustomUserStatuses
            { Set-MMUserCustomStatus -UserId $script:AdminUser.id -Emoji 'house' -Text 'WFH' -Duration 'today' } |
                Should -Not -Throw
        }

        It 'принимает объект MMUser из пайплайна' {
            { $script:AdminUser | Set-MMUserCustomStatus -Emoji 'coffee' -Text 'On break' } |
                Should -Not -Throw
        }
    }

    Context 'Снятие кастомного статуса' {
        It 'удаляет кастомный статус без ошибок' {
            { Remove-MMUserCustomStatus -UserId $script:AdminUser.id } | Should -Not -Throw
        }

        It 'принимает объект MMUser из пайплайна' {
            Set-MMUserCustomStatus -UserId $script:AdminUser.id -Emoji 'zzz' -Text 'Away'
            { $script:AdminUser | Remove-MMUserCustomStatus } | Should -Not -Throw
        }
    }
}
