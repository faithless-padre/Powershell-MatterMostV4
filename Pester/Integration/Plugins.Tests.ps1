# Интеграционные тесты для командлетов управления плагинами MatterMostV4

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

    $script:Suffix  = (Get-Date -Format 'HHmmss')
    $script:Plugins = $null

    try {
        $script:Plugins = Get-MMPlugin
    } catch {
        Write-Warning "Не удалось получить список плагинов: $_"
    }
}

Describe 'Get-MMPlugin' {

    Context 'Получение списка плагинов' {
        It 'не бросает исключение' {
            { Get-MMPlugin } | Should -Not -Throw
        }

        It 'результат содержит свойство active' {
            $result = Get-MMPlugin
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'active'
        }

        It 'результат содержит свойство inactive' {
            $result = Get-MMPlugin
            $result.PSObject.Properties.Name | Should -Contain 'inactive'
        }
    }
}

Describe 'Get-MMPluginStatus' {

    Context 'Получение статусов плагинов' {
        It 'не бросает исключение' {
            { Get-MMPluginStatus } | Should -Not -Throw
        }

        It 'возвращает массив или пустой результат' {
            # Статусы могут быть пустыми если плагинов нет или одна нода — это нормально
            $result = Get-MMPluginStatus
            # Не валидируем содержимое — просто убеждаемся что команда отрабатывает
            $result | Should -BeOfType [object]
        }

        It 'если есть статусы — у каждого есть поле plugin_id' {
            $result = Get-MMPluginStatus
            if ($result -and @($result).Count -gt 0) {
                $result[0].PSObject.Properties.Name | Should -Contain 'plugin_id'
            } else {
                Set-ItResult -Skipped -Because 'плагинов с активными статусами нет'
            }
        }

        It 'если есть статусы — у каждого есть поле state' {
            $result = Get-MMPluginStatus
            if ($result -and @($result).Count -gt 0) {
                $result[0].PSObject.Properties.Name | Should -Contain 'state'
            } else {
                Set-ItResult -Skipped -Because 'плагинов с активными статусами нет'
            }
        }
    }
}

Describe 'Install-MMPlugin' {

    Context 'Установка плагина по URL' {
        It 'устанавливает плагин по URL' -Skip:($true) {
            # Пропускаем: нужен реальный URL плагина .tar.gz
        }
    }

    Context 'Установка плагина из файла' {
        It 'устанавливает плагин из локального .tar.gz' -Skip:($true) {
            # Пропускаем: нужен реальный файл плагина .tar.gz
        }
    }
}

Describe 'Enable-MMPlugin' {

    Context 'Включение плагина' {
        It 'включает неактивный плагин' -Skip:($null -eq $script:Plugins -or $null -eq $script:Plugins.inactive -or @($script:Plugins.inactive).Count -eq 0) {
            $plugin = @($script:Plugins.inactive)[0]

            { Enable-MMPlugin -PluginId $plugin.id } | Should -Not -Throw

            # Убираем за собой — отключаем обратно чтобы не ломать состояние сервера
            try { Disable-MMPlugin -PluginId $plugin.id } catch { }
        }

        It 'включает плагин через пайплайн' -Skip:($null -eq $script:Plugins -or $null -eq $script:Plugins.inactive -or @($script:Plugins.inactive).Count -eq 0) {
            $plugin = @($script:Plugins.inactive)[0]

            { $plugin | Enable-MMPlugin } | Should -Not -Throw

            try { Disable-MMPlugin -PluginId $plugin.id } catch { }
        }

        It 'бросает исключение при несуществующем PluginId' {
            { Enable-MMPlugin -PluginId 'com.nonexistent.plugin.that.does.not.exist' } | Should -Throw
        }
    }
}

Describe 'Disable-MMPlugin' {

    Context 'Отключение плагина' {
        It 'отключает активный плагин' -Skip:($null -eq $script:Plugins -or $null -eq $script:Plugins.active -or @($script:Plugins.active).Count -eq 0) {
            $plugin = @($script:Plugins.active)[0]

            { Disable-MMPlugin -PluginId $plugin.id } | Should -Not -Throw

            # Возвращаем плагин в исходное состояние
            try { Enable-MMPlugin -PluginId $plugin.id } catch { }
        }

        It 'отключает плагин через пайплайн' -Skip:($null -eq $script:Plugins -or $null -eq $script:Plugins.active -or @($script:Plugins.active).Count -eq 0) {
            $plugin = @($script:Plugins.active)[0]

            { $plugin | Disable-MMPlugin } | Should -Not -Throw

            try { Enable-MMPlugin -PluginId $plugin.id } catch { }
        }

        It 'бросает исключение при несуществующем PluginId' {
            { Disable-MMPlugin -PluginId 'com.nonexistent.plugin.that.does.not.exist' } | Should -Throw
        }
    }
}

Describe 'Remove-MMPlugin' {

    Context 'Удаление плагина' {
        It 'удаляет неактивный плагин' -Skip:($null -eq $script:Plugins -or $null -eq $script:Plugins.inactive -or @($script:Plugins.inactive).Count -eq 0) {
            # Берём второй неактивный, чтобы не мешать тестам Enable/Disable которые тоже используют первый
            $inactive = @($script:Plugins.inactive)
            if ($inactive.Count -lt 2) {
                Set-ItResult -Skipped -Because 'недостаточно неактивных плагинов для теста удаления'
                return
            }

            $plugin = $inactive[1]
            { Remove-MMPlugin -PluginId $plugin.id } | Should -Not -Throw
        }

        It 'удаляет плагин через пайплайн' -Skip:($null -eq $script:Plugins -or $null -eq $script:Plugins.inactive -or @($script:Plugins.inactive).Count -eq 0) {
            $inactive = @($script:Plugins.inactive)
            if ($inactive.Count -lt 3) {
                Set-ItResult -Skipped -Because 'недостаточно неактивных плагинов для теста удаления через пайплайн'
                return
            }

            $plugin = $inactive[2]
            { $plugin | Remove-MMPlugin } | Should -Not -Throw
        }

        It 'бросает исключение при несуществующем PluginId' {
            { Remove-MMPlugin -PluginId 'com.nonexistent.plugin.that.does.not.exist' } | Should -Throw
        }
    }
}
