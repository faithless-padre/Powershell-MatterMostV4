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

Describe 'New-MMBot / Get-MMBot' {

    Context 'Создание бота' {
        It 'создаёт бота и возвращает MMBot объект' {
            $name   = "pesterbot$(Get-Date -Format 'HHmmss')"
            $result = New-MMBot -Username $name -DisplayName 'Pester Bot' -Description 'Created by Pester'

            $result                | Should -Not -BeNullOrEmpty
            $result.user_id        | Should -Not -BeNullOrEmpty
            $result.username       | Should -Be $name
            $result.display_name   | Should -Be 'Pester Bot'
            $result.description    | Should -Be 'Created by Pester'
            $result.GetType().Name | Should -Be 'MMBot'

            $script:Bot = $result
        }

        It 'создаёт бота без опциональных полей' {
            $name   = "pesterbotmin$(Get-Date -Format 'HHmmss')"
            $result = New-MMBot -Username $name

            $result.username       | Should -Be $name
            $result.GetType().Name | Should -Be 'MMBot'

            Disable-MMBot -BotUserId $result.user_id
        }
    }

    Context 'Получение ботов' {
        It 'возвращает бота по BotUserId' {
            $result = Get-MMBot -BotUserId $script:Bot.user_id

            $result.user_id        | Should -Be $script:Bot.user_id
            $result.GetType().Name | Should -Be 'MMBot'
        }

        It 'возвращает список ботов' {
            $result = Get-MMBot

            $result               | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMBot'
        }

        It 'возвращает список с IncludeDeleted' {
            $result = Get-MMBot -IncludeDeleted

            $result | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение при невалидном BotUserId' {
            { Get-MMBot -BotUserId 'invalid-bot-id' } | Should -Throw
        }
    }
}

Describe 'Set-MMBot' {

    Context 'Обновление бота' {
        It 'обновляет display_name и description бота' {
            $result = Set-MMBot -BotUserId $script:Bot.user_id -DisplayName 'Pester Bot Updated' -Description 'Updated by Pester'

            $result.user_id      | Should -Be $script:Bot.user_id
            $result.display_name | Should -Be 'Pester Bot Updated'
            $result.GetType().Name | Should -Be 'MMBot'
        }

        It 'принимает объект MMBot из пайплайна' {
            $result = $script:Bot | Set-MMBot -DisplayName 'Pester Bot Pipeline'

            $result.display_name | Should -Be 'Pester Bot Pipeline'
        }
    }
}

Describe 'Set-MMBotOwner' {

    Context 'Переназначение владельца' {
        It 'назначает нового владельца по OwnerId' {
            $result = Set-MMBotOwner -BotUserId $script:Bot.user_id -OwnerId $script:TestUser.id

            $result.user_id  | Should -Be $script:Bot.user_id
            $result.owner_id | Should -Be $script:TestUser.id
        }

        It 'назначает нового владельца по OwnerName' {
            $result = Set-MMBotOwner -BotUserId $script:Bot.user_id -OwnerName $script:AdminUser.username

            $result.owner_id | Should -Be $script:AdminUser.id
        }

        It 'принимает объект MMBot из пайплайна' {
            $result = $script:Bot | Set-MMBotOwner -OwnerId $script:AdminUser.id

            $result.owner_id | Should -Be $script:AdminUser.id
        }
    }
}

Describe 'New-MMUserToken для бота' {

    Context 'Создание токена для бота' {
        It 'создаёт PAT для бота' {
            $result = New-MMUserToken -UserId $script:Bot.user_id -Description 'Pester bot token'

            $result.token          | Should -Not -BeNullOrEmpty
            $result.user_id        | Should -Be $script:Bot.user_id
            $result.GetType().Name | Should -Be 'MMUserToken'

            Revoke-MMUserToken -TokenId $result.id
        }
    }
}

Describe 'Disable-MMBot / Enable-MMBot' {

    Context 'Отключение и включение бота' {
        It 'отключает бота' {
            $result = Disable-MMBot -BotUserId $script:Bot.user_id

            $result.user_id        | Should -Be $script:Bot.user_id
            $result.delete_at      | Should -BeGreaterThan 0
            $result.GetType().Name | Should -Be 'MMBot'
        }

        It 'включает бота обратно' {
            $result = Enable-MMBot -BotUserId $script:Bot.user_id

            $result.user_id   | Should -Be $script:Bot.user_id
            $result.delete_at | Should -Be 0
        }

        It 'принимает объект MMBot из пайплайна (disable)' {
            { $script:Bot | Disable-MMBot } | Should -Not -Throw
        }

        It 'принимает объект MMBot из пайплайна (enable)' {
            { $script:Bot | Enable-MMBot } | Should -Not -Throw
        }
    }

    Context 'OnlyOrphaned' {
        It 'возвращает список (возможно пустой) ботов-сирот' {
            { Get-MMBot -OnlyOrphaned } | Should -Not -Throw
        }
    }
}
