BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
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
}

Describe 'New-MMUserToken / Get-MMUserToken' {

    Context 'Создание токена' {
        It 'создаёт токен и возвращает MMUserToken с токеном' {
            $result = New-MMUserToken -UserId $script:AdminUser.id -Description 'Pester test token'

            $result                | Should -Not -BeNullOrEmpty
            $result.id             | Should -Not -BeNullOrEmpty
            $result.token          | Should -Not -BeNullOrEmpty
            $result.user_id        | Should -Be $script:AdminUser.id
            $result.description    | Should -Be 'Pester test token'
            $result.GetType().Name | Should -Be 'MMUserToken'

            $script:Token = $result
        }

        It 'создаёт токен через пайп из MMUser' {
            $result = $script:AdminUser | New-MMUserToken -Description 'Pester pipeline token'

            $result.token          | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'MMUserToken'

            # Отзываем сразу — нам он не нужен
            Revoke-MMUserToken -TokenId $result.id
        }
    }

    Context 'Получение токенов' {
        It 'возвращает список токенов пользователя' {
            $result = Get-MMUserToken -UserId $script:AdminUser.id

            $result               | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMUserToken'
        }

        It 'возвращает список токенов через пайп из MMUser' {
            $result = $script:AdminUser | Get-MMUserToken

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает конкретный токен по TokenId' {
            $result = Get-MMUserToken -TokenId $script:Token.id

            $result.id      | Should -Be $script:Token.id
            $result.user_id | Should -Be $script:AdminUser.id
            # Sanitized ответ — token value не возвращается
            $result.GetType().Name | Should -Be 'MMUserToken'
        }

        It 'бросает исключение при невалидном TokenId' {
            { Get-MMUserToken -TokenId 'invalid-token-id' } | Should -Throw
        }
    }
}

Describe 'Revoke-MMUserToken' {

    Context 'Отзыв токена' {
        It 'отзывает токен без ошибок' {
            { Revoke-MMUserToken -TokenId $script:Token.id } | Should -Not -Throw
        }

        It 'отзывает токен через пайп из MMUserToken' {
            $token = New-MMUserToken -UserId $script:AdminUser.id -Description 'Pester revoke pipeline'
            { $token | Revoke-MMUserToken } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TokenId' {
            { Revoke-MMUserToken -TokenId 'invalid-token-id' } | Should -Throw
        }
    }
}
