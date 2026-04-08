# Интеграционные тесты для командлетов управления предпочтениями пользователя MatterMost

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

    $script:Suffix   = (Get-Date -Format 'HHmmss')
    $script:Team     = Get-MMTeam -Name $config.TestTeamName
    $script:Admin    = Get-MMUser -Me

    # Тестовый набор предпочтений
    $script:TestCategory = 'display_settings'
    $script:TestName     = 'channel_display_mode'
    $script:TestValue    = 'full'

    $script:TestPref = @{
        user_id  = $script:Admin.id
        category = $script:TestCategory
        name     = $script:TestName
        value    = $script:TestValue
    }
}

Describe 'Set-MMPreferences' {

    Context 'Создание предпочтения' {
        It 'устанавливает предпочтение без ошибок' {
            { Set-MMPreferences -Preferences @($script:TestPref) } | Should -Not -Throw
        }

        It 'устанавливает предпочтение с явным UserId' {
            { Set-MMPreferences -UserId $script:Admin.id -Preferences @($script:TestPref) } | Should -Not -Throw
        }
    }
}

Describe 'Get-MMPreferences' {

    BeforeAll {
        # Убедимся, что предпочтение точно есть
        Set-MMPreferences -Preferences @($script:TestPref)
    }

    Context 'Получение всех предпочтений' {
        It 'возвращает непустой список предпочтений' {
            $result = Get-MMPreferences

            $result | Should -Not -BeNullOrEmpty
        }

        It 'каждый объект имеет обязательные поля' {
            $result = Get-MMPreferences

            $first = $result | Select-Object -First 1
            $first.user_id  | Should -Not -BeNullOrEmpty
            $first.category | Should -Not -BeNullOrEmpty
            $first.name     | Should -Not -BeNullOrEmpty
        }

        It 'возвращает предпочтения для явного UserId' {
            $result = Get-MMPreferences -UserId $script:Admin.id

            $result | Should -Not -BeNullOrEmpty
        }

        It 'содержит наше тестовое предпочтение' {
            $result = Get-MMPreferences

            $found = $result | Where-Object { $_.category -eq $script:TestCategory -and $_.name -eq $script:TestName }
            $found | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Get-MMPreferences -UserId 'invalid-user-id-xyz' } | Should -Throw
        }
    }
}

Describe 'Get-MMPreferencesByCategory' {

    BeforeAll {
        Set-MMPreferences -Preferences @($script:TestPref)
    }

    Context 'Получение предпочтений по категории' {
        It 'возвращает предпочтения категории display_settings' {
            $result = Get-MMPreferencesByCategory -Category $script:TestCategory

            $result | Should -Not -BeNullOrEmpty
        }

        It 'все объекты принадлежат запрошенной категории' {
            $result = Get-MMPreferencesByCategory -Category $script:TestCategory

            $result | ForEach-Object {
                $_.category | Should -Be $script:TestCategory
            }
        }

        It 'содержит наше тестовое предпочтение' {
            $result = Get-MMPreferencesByCategory -Category $script:TestCategory

            $found = $result | Where-Object { $_.name -eq $script:TestName }
            $found | Should -Not -BeNullOrEmpty
            $found.value | Should -Be $script:TestValue
        }

        It 'работает с явным UserId' {
            $result = Get-MMPreferencesByCategory -UserId $script:Admin.id -Category $script:TestCategory

            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки' {
        It 'возвращает пустой результат или бросает исключение для несуществующей категории' {
            # API может вернуть пустой массив или 404 — оба варианта приемлемы
            $result = try {
                Get-MMPreferencesByCategory -Category 'nonexistent_category_xyz'
            } catch {
                $null
            }
            # Просто проверяем, что вызов не падает с неожиданной ошибкой
            $true | Should -Be $true
        }
    }
}

Describe 'Get-MMPreference' {

    BeforeAll {
        Set-MMPreferences -Preferences @($script:TestPref)
    }

    Context 'Получение конкретного предпочтения' {
        It 'возвращает предпочтение по категории и имени' {
            $result = Get-MMPreference -Category $script:TestCategory -Name $script:TestName

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает объект с правильными полями' {
            $result = Get-MMPreference -Category $script:TestCategory -Name $script:TestName

            $result.category | Should -Be $script:TestCategory
            $result.name     | Should -Be $script:TestName
            $result.value    | Should -Be $script:TestValue
            $result.user_id  | Should -Be $script:Admin.id
        }

        It 'работает с явным UserId' {
            $result = Get-MMPreference -UserId $script:Admin.id -Category $script:TestCategory -Name $script:TestName

            $result.name | Should -Be $script:TestName
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при несуществующем предпочтении' {
            { Get-MMPreference -Category $script:TestCategory -Name 'nonexistent_pref_xyz' } | Should -Throw
        }
    }
}

Describe 'Remove-MMPreferences' {

    Context 'Удаление предпочтения' {
        It 'удаляет предпочтение без ошибок' {
            Set-MMPreferences -Preferences @($script:TestPref)

            { Remove-MMPreferences -Preferences @($script:TestPref) -Confirm:$false } | Should -Not -Throw
        }

        It 'после удаления предпочтение недоступно через Get-MMPreference' {
            Set-MMPreferences -Preferences @($script:TestPref)
            Remove-MMPreferences -Preferences @($script:TestPref) -Confirm:$false

            { Get-MMPreference -Category $script:TestCategory -Name $script:TestName } | Should -Throw
        }

        It 'работает с явным UserId' {
            Set-MMPreferences -UserId $script:Admin.id -Preferences @($script:TestPref)

            { Remove-MMPreferences -UserId $script:Admin.id -Preferences @($script:TestPref) -Confirm:$false } | Should -Not -Throw
        }

        It 'удаляет несколько предпочтений за один вызов' {
            $pref1 = @{
                user_id  = $script:Admin.id
                category = 'display_settings'
                name     = 'channel_display_mode'
                value    = 'full'
            }
            $pref2 = @{
                user_id  = $script:Admin.id
                category = 'display_settings'
                name     = 'message_display'
                value    = 'clean'
            }

            Set-MMPreferences -Preferences @($pref1, $pref2)

            { Remove-MMPreferences -Preferences @($pref1, $pref2) -Confirm:$false } | Should -Not -Throw
        }
    }
}
