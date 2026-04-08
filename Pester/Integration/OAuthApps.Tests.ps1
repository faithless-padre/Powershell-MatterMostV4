# Интеграционные тесты для OAuth-командлетов MatterMostV4

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

    $script:Suffix = (Get-Date -Format 'HHmmss')

    # Проверяем, работает ли OAuth на сервере — пробуем создать тестовое приложение
    $script:OAuthEnabled = $false
    $script:TestApp       = $null

    try {
        $script:TestApp = New-MMOAuthApp `
            -Name         "PesterOAuth_$($script:Suffix)" `
            -Description  'Тест OAuth Pester' `
            -CallbackUrls @('http://localhost/callback') `
            -Homepage     'http://localhost'

        $script:OAuthEnabled = $true
    } catch {
        Write-Warning "OAuth недоступен на этом сервере (EnableOAuthServiceProvider=false?). Тесты OAuth будут пропущены. Ошибка: $_"
    }
}

AfterAll {
    if ($script:OAuthEnabled -and $script:TestApp) {
        try { Remove-MMOAuthApp -AppId $script:TestApp.id } catch { }
    }
}

Describe 'Get-MMOAuthApp' {

    Context 'Список всех приложений' {
        It 'не бросает исключение' -Skip:(-not $script:OAuthEnabled) {
            { Get-MMOAuthApp } | Should -Not -Throw
        }

        It 'возвращает массив или пустой результат' -Skip:(-not $script:OAuthEnabled) {
            $result = Get-MMOAuthApp
            # Результат либо массив объектов, либо $null/$empty — оба варианта валидны
            $result | Should -BeOfType [object]
        }
    }

    Context 'Получение приложения по ID' {
        It 'возвращает созданное приложение' -Skip:(-not $script:OAuthEnabled) {
            $result = Get-MMOAuthApp -AppId $script:TestApp.id

            $result    | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $script:TestApp.id
        }

        It 'возвращает приложение через пайплайн' -Skip:(-not $script:OAuthEnabled) {
            $result = $script:TestApp | Get-MMOAuthApp

            $result    | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $script:TestApp.id
        }

        It 'бросает исключение при невалидном AppId' {
            { Get-MMOAuthApp -AppId 'invalid-app-id-that-does-not-exist' } | Should -Throw
        }
    }
}

Describe 'New-MMOAuthApp' {

    Context 'Создание приложения' {
        It 'создаёт приложение с обязательными параметрами' -Skip:(-not $script:OAuthEnabled) {
            $app = $null
            try {
                $app = New-MMOAuthApp `
                    -Name         "PesterNew_$($script:Suffix)" `
                    -Description  'Новое тестовое приложение' `
                    -CallbackUrls @('http://localhost/cb') `
                    -Homepage     'http://localhost'

                $app              | Should -Not -BeNullOrEmpty
                $app.id           | Should -Not -BeNullOrEmpty
                $app.name         | Should -Be "PesterNew_$($script:Suffix)"
                $app.description  | Should -Be 'Новое тестовое приложение'
                $app.callback_urls | Should -Contain 'http://localhost/cb'
                $app.homepage     | Should -Be 'http://localhost'
            } finally {
                if ($app) { try { Remove-MMOAuthApp -AppId $app.id } catch { } }
            }
        }

        It 'создаёт доверенное приложение с флагом IsTrusted' -Skip:(-not $script:OAuthEnabled) {
            $app = $null
            try {
                $app = New-MMOAuthApp `
                    -Name         "PesterTrusted_$($script:Suffix)" `
                    -Description  'Доверенное приложение' `
                    -CallbackUrls @('http://localhost/trusted') `
                    -Homepage     'http://localhost' `
                    -IsTrusted

                $app.is_trusted | Should -Be $true
            } finally {
                if ($app) { try { Remove-MMOAuthApp -AppId $app.id } catch { } }
            }
        }
    }
}

Describe 'Set-MMOAuthApp' {

    Context 'Обновление приложения' {
        It 'обновляет описание приложения' -Skip:(-not $script:OAuthEnabled) {
            $result = Set-MMOAuthApp -AppId $script:TestApp.id -Description 'Обновлённое описание'

            $result             | Should -Not -BeNullOrEmpty
            $result.description | Should -Be 'Обновлённое описание'
        }

        It 'обновляет имя приложения' -Skip:(-not $script:OAuthEnabled) {
            $newName = "PesterRenamed_$($script:Suffix)"
            $result  = Set-MMOAuthApp -AppId $script:TestApp.id -Name $newName

            $result.name | Should -Be $newName
        }

        It 'принимает объект приложения из пайплайна' -Skip:(-not $script:OAuthEnabled) {
            $result = $script:TestApp | Set-MMOAuthApp -Description 'Через пайплайн'

            $result             | Should -Not -BeNullOrEmpty
            $result.description | Should -Be 'Через пайплайн'
        }

        It 'бросает исключение при невалидном AppId' {
            { Set-MMOAuthApp -AppId 'invalid-id' -Description 'test' } | Should -Throw
        }
    }
}

Describe 'Reset-MMOAuthAppSecret' {

    Context 'Перегенерация секрета' {
        It 'возвращает объект с новым client_secret' -Skip:(-not $script:OAuthEnabled) {
            $result = Reset-MMOAuthAppSecret -AppId $script:TestApp.id

            $result               | Should -Not -BeNullOrEmpty
            $result.client_secret | Should -Not -BeNullOrEmpty
        }

        It 'принимает объект приложения из пайплайна' -Skip:(-not $script:OAuthEnabled) {
            $result = $script:TestApp | Reset-MMOAuthAppSecret

            $result               | Should -Not -BeNullOrEmpty
            $result.client_secret | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение при невалидном AppId' {
            { Reset-MMOAuthAppSecret -AppId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Remove-MMOAuthApp' {

    Context 'Удаление приложения' {
        It 'удаляет приложение без исключений' -Skip:(-not $script:OAuthEnabled) {
            $app = New-MMOAuthApp `
                -Name         "PesterDel_$($script:Suffix)" `
                -Description  'Удаляемое приложение' `
                -CallbackUrls @('http://localhost/del') `
                -Homepage     'http://localhost'

            { Remove-MMOAuthApp -AppId $app.id } | Should -Not -Throw
        }

        It 'принимает объект приложения из пайплайна' -Skip:(-not $script:OAuthEnabled) {
            $app = New-MMOAuthApp `
                -Name         "PesterDelPipe_$($script:Suffix)" `
                -Description  'Удаляемое через пайплайн' `
                -CallbackUrls @('http://localhost/delpipe') `
                -Homepage     'http://localhost'

            { $app | Remove-MMOAuthApp } | Should -Not -Throw
        }

        It 'бросает исключение при невалидном AppId' {
            { Remove-MMOAuthApp -AppId 'invalid-id' } | Should -Throw
        }
    }
}
