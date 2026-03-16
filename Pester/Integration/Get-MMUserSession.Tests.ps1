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
    $script:AdminUser = Get-MMUser -Username $config.AdminUsername
}

Describe 'Get-MMUserSession' {

    Context 'Список сессий' {
        It 'возвращает список сессий без ошибок' {
            $result = Get-MMUserSession -UserId $script:AdminUser.id
            $result | Should -Not -BeNullOrEmpty
        }

        It 'сессии содержат обязательные поля' {
            $session = Get-MMUserSession -UserId $script:AdminUser.id | Select-Object -First 1
            $session.id         | Should -Not -BeNullOrEmpty
            $session.user_id    | Should -Be $script:AdminUser.id
            $session.create_at  | Should -BeGreaterThan 0
        }

        It 'принимает объект пользователя из пайплайна' {
            $result = $script:AdminUser | Get-MMUserSession
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Get-MMUserSession -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }
}

Describe 'Revoke-MMUserSession' {

    Context 'Отзыв сессии' {
        It 'отзывает конкретную сессию без ошибок' {
            # Создаём новую сессию
            $secPass  = ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password $secPass | Out-Null
            $sessions = Get-MMUserSession -UserId $script:AdminUser.id
            $session  = $sessions | Select-Object -Last 1

            { Revoke-MMUserSession -UserId $script:AdminUser.id -SessionId $session.id } | Should -Not -Throw
        }

        It 'принимает объект сессии из пайплайна' {
            $secPass = ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password $secPass | Out-Null
            $session = Get-MMUserSession -UserId $script:AdminUser.id | Select-Object -Last 1

            { $session | Revoke-MMUserSession } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном SessionId' {
            { Revoke-MMUserSession -UserId $script:AdminUser.id -SessionId 'invalid-session' } | Should -Throw
        }
    }
}

Describe 'Revoke-MMAllUserSessions' {

    Context 'Отзыв всех сессий' {
        It 'отзывает все сессии без ошибок' {
            # Создаём тестового пользователя
            $suffix   = (Get-Date -Format 'HHmmss')
            $secPass  = ConvertTo-SecureString 'Pester123!' -AsPlainText -Force
            $testUser = New-MMUser -Username "sesstest_$suffix" -Email "sesstest_$suffix@test.com" -Password $secPass

            { Revoke-MMAllUserSessions -UserId $testUser.id } | Should -Not -Throw

            Remove-MMUser -UserId $testUser.id
        }

        It 'принимает объект пользователя из пайплайна' {
            $suffix   = (Get-Date -Format 'HHmmss')
            $secPass  = ConvertTo-SecureString 'Pester123!' -AsPlainText -Force
            $testUser = New-MMUser -Username "sesstest2_$suffix" -Email "sesstest2_$suffix@test.com" -Password $secPass

            { $testUser | Revoke-MMAllUserSessions } | Should -Not -Throw

            Remove-MMUser -UserId $testUser.id
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Revoke-MMAllUserSessions -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }
}
