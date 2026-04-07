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
}

Describe 'Test-MMServer' {

    Context 'Проверка здоровья сервера' {
        It 'возвращает результат со статусом OK' {
            $result = Test-MMServer

            $result        | Should -Not -BeNullOrEmpty
            $result.status | Should -Be 'OK'
        }
    }
}

Describe 'Get-MMServerConfig' {

    Context 'Получение конфигурации сервера' {
        It 'возвращает объект конфигурации с ServiceSettings' {
            $result = Get-MMServerConfig

            $result                           | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name  | Should -Contain 'ServiceSettings'
        }
    }
}

Describe 'Set-MMServerConfig' {

    Context 'Обновление конфигурации сервера' {
        It 'пропускается — деструктивная операция' -Skip:($true) {
            # Изменение конфигурации сервера в тестах опасно
        }
    }
}

Describe 'Get-MMServerLogs' {

    Context 'Получение логов сервера' {
        It 'возвращает непустой массив записей лога' {
            $result = Get-MMServerLogs -PerPage 100

            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Add-MMServerLogEntry' {

    Context 'Запись в лог сервера' {
        It 'записывает info-сообщение без ошибок' {
            { Add-MMServerLogEntry -Level 'info' -Message 'Pester test log entry' } | Should -Not -Throw
        }
    }
}

Describe 'Clear-MMServerCaches' {

    Context 'Инвалидация кешей' {
        It 'инвалидирует кеши без ошибок' {
            { Clear-MMServerCaches } | Should -Not -Throw
        }
    }
}

Describe 'Get-MMServerAudits' {

    Context 'Получение аудит-лога' {
        It 'возвращает массив объектов MMAudit' {
            $result = Get-MMServerAudits -PerPage 10

            $result                   | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMAudit'
        }
    }
}

Describe 'Test-MMEmail' {

    Context 'Отправка тестового письма' {
        It 'пропускается — реальная отправка письма' -Skip:($true) {
            # Реальная отправка email в тестах нежелательна
            { Test-MMEmail } | Should -Not -Throw
        }
    }
}

Describe 'Get-MMServerTimezones' {

    Context 'Получение списка таймзон' {
        It 'возвращает непустой массив строк, содержащий UTC' {
            $result = Get-MMServerTimezones

            $result          | Should -Not -BeNullOrEmpty
            $result          | Should -Contain 'UTC'
        }
    }
}

Describe 'Get-MMLicenseInfo' {

    Context 'Получение информации о лицензии' {
        It 'возвращает объект с информацией о лицензии' {
            $result = Get-MMLicenseInfo

            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Get-MMServerAnalytics' {

    Context 'Получение аналитики сервера' {
        It 'возвращает данные standard-аналитики' -Skip:($true) {
            # Analytics endpoint requires Enterprise license (returns 404 on Team Edition)
            $result = Get-MMServerAnalytics
            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Invoke-MMDatabaseRecycle' {

    Context 'Переподключение БД' {
        It 'переподключает соединения без ошибок' {
            { Invoke-MMDatabaseRecycle } | Should -Not -Throw
        }
    }
}
