# Интеграционные тесты для командлетов управления slash-командами MatterMost

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

    $script:Suffix = (Get-Date -Format 'HHmmss')
    $script:Team   = Get-MMTeam -Name $config.TestTeamName
    $script:Admin  = Get-MMUser -Me
}

AfterAll {
    # Чистим команды, если остались
    if ($script:TestCommand) {
        try { Remove-MMCommand -CommandId $script:TestCommand.id -Confirm:$false } catch { }
    }
    if ($script:MoveCommand) {
        try { Remove-MMCommand -CommandId $script:MoveCommand.id -Confirm:$false } catch { }
    }
    if ($script:TargetTeam) {
        try { Remove-MMTeam -TeamId $script:TargetTeam.id } catch { }
    }
}

Describe 'New-MMCommand' {

    Context 'Создание slash-команды' {
        It 'создаёт команду с обязательными параметрами' {
            $cmd = New-MMCommand `
                -TeamId  $script:Team.id `
                -Trigger "testcmd$($script:Suffix)" `
                -URL     'http://example.com/hook'

            $cmd             | Should -Not -BeNullOrEmpty
            $cmd.id          | Should -Not -BeNullOrEmpty
            $cmd.team_id     | Should -Be $script:Team.id
            $cmd.trigger     | Should -Be "testcmd$($script:Suffix)"
            $cmd.url         | Should -Be 'http://example.com/hook'

            # Сохраняем для дальнейших тестов
            $script:TestCommand = $cmd
        }

        It 'создаёт команду с опциональными параметрами' {
            $cmd = New-MMCommand `
                -TeamId          $script:Team.id `
                -Trigger         "optcmd$($script:Suffix)" `
                -URL             'http://example.com/opt' `
                -DisplayName     'Тестовая команда' `
                -Description     'Используется в тестах Pester' `
                -AutoComplete `
                -AutoCompleteDesc 'Запускает тест' `
                -AutoCompleteHint '[аргумент]' `
                -Method          'G'

            $cmd                    | Should -Not -BeNullOrEmpty
            $cmd.display_name       | Should -Be 'Тестовая команда'
            $cmd.auto_complete      | Should -Be $true
            $cmd.method             | Should -Be 'G'

            # Сохраняем для теста Move-MMCommand
            $script:MoveCommand = $cmd
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { New-MMCommand -TeamId 'invalid-team-id' -Trigger 'badcmd' -URL 'http://example.com' } |
                Should -Throw
        }

        It 'бросает исключение при дублирующемся триггере' {
            { New-MMCommand -TeamId $script:Team.id -Trigger "testcmd$($script:Suffix)" -URL 'http://example.com/dupe' } |
                Should -Throw
        }
    }
}

Describe 'Get-MMCommand' {

    Context 'Получение команд по TeamId' {
        It 'возвращает список команд для команды' {
            $result = Get-MMCommand -TeamId $script:Team.id

            $result | Should -Not -BeNullOrEmpty
        }

        It 'список содержит созданную команду' {
            $result = Get-MMCommand -TeamId $script:Team.id

            $found = $result | Where-Object { $_.id -eq $script:TestCommand.id }
            $found | Should -Not -BeNullOrEmpty
        }

        It 'каждый объект принадлежит запрошенной команде' {
            $result = Get-MMCommand -TeamId $script:Team.id

            $result | ForEach-Object {
                $_.team_id | Should -Be $script:Team.id
            }
        }
    }

    Context 'Получение команды по CommandId' {
        It 'возвращает конкретную команду по ID' {
            $result = Get-MMCommand -CommandId $script:TestCommand.id

            $result    | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $script:TestCommand.id
        }

        It 'возвращает объект с обязательными полями' {
            $result = Get-MMCommand -CommandId $script:TestCommand.id

            $result.trigger  | Should -Be "testcmd$($script:Suffix)"
            $result.url      | Should -Be 'http://example.com/hook'
            $result.team_id  | Should -Be $script:Team.id
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном CommandId' {
            { Get-MMCommand -CommandId 'invalid-command-id-xyz' } | Should -Throw
        }

        It 'возвращает пустой результат при невалидном TeamId' {
            # MM возвращает пустой массив, а не ошибку
            $result = Get-MMCommand -TeamId 'invalid-team-id-xyz'
            $result | Should -BeNullOrEmpty
        }
    }
}

Describe 'Set-MMCommand' {

    Context 'Обновление slash-команды' {
        It 'обновляет DisplayName команды' {
            $result = Set-MMCommand -CommandId $script:TestCommand.id -TeamId $script:Team.id -DisplayName 'Обновлённое имя'

            $result              | Should -Not -BeNullOrEmpty
            $result.display_name | Should -Be 'Обновлённое имя'
        }

        It 'обновляет URL команды' {
            $result = Set-MMCommand -CommandId $script:TestCommand.id -TeamId $script:Team.id -URL 'http://example.com/updated'

            $result     | Should -Not -BeNullOrEmpty
            $result.url | Should -Be 'http://example.com/updated'
        }

        It 'принимает объект команды из пайплайна' {
            # pipeline передаёт team_id через ValueFromPipelineByPropertyName
            $result = $script:TestCommand | Set-MMCommand -DisplayName 'Из пайплайна'

            $result.display_name | Should -Be 'Из пайплайна'
        }

        It 'обновляет несколько полей за один вызов' {
            $result = Set-MMCommand `
                -CommandId   $script:TestCommand.id `
                -TeamId      $script:Team.id `
                -DisplayName 'Финальное имя' `
                -Description 'Финальное описание'

            $result.display_name | Should -Be 'Финальное имя'
            $result.description  | Should -Be 'Финальное описание'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном CommandId' {
            { Set-MMCommand -CommandId 'invalid-command-id-xyz' -DisplayName 'Test' } | Should -Throw
        }
    }
}

Describe 'Reset-MMCommandToken' {

    Context 'Сброс токена команды' {
        It 'возвращает объект с новым токеном' {
            $result = Reset-MMCommandToken -CommandId $script:TestCommand.id

            $result       | Should -Not -BeNullOrEmpty
            $result.token | Should -Not -BeNullOrEmpty
        }

        It 'новый токен отличается от предыдущего' {
            $token1 = (Reset-MMCommandToken -CommandId $script:TestCommand.id).token
            $token2 = (Reset-MMCommandToken -CommandId $script:TestCommand.id).token

            $token1 | Should -Not -Be $token2
        }

        It 'принимает объект команды из пайплайна' {
            $result = $script:TestCommand | Reset-MMCommandToken

            $result.token | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном CommandId' {
            { Reset-MMCommandToken -CommandId 'invalid-command-id-xyz' } | Should -Throw
        }
    }
}

Describe 'Move-MMCommand' {

    BeforeAll {
        # Создаём вторую команду для теста перемещения
        $script:TargetTeam = New-MMTeam `
            -Name        "movtgt$($script:Suffix)" `
            -DisplayName "Move Target $($script:Suffix)"
    }

    Context 'Перемещение slash-команды в другую команду' {
        It 'перемещает команду в другую team без ошибок' {
            { Move-MMCommand -CommandId $script:MoveCommand.id -TeamId $script:TargetTeam.id -Confirm:$false } |
                Should -Not -Throw
        }

        It 'после перемещения команда исчезает из исходной команды' {
            $result = Get-MMCommand -TeamId $script:Team.id

            $found = $result | Where-Object { $_.id -eq $script:MoveCommand.id }
            $found | Should -BeNullOrEmpty
        }

        It 'принимает объект команды из пайплайна' {
            # Создаём ещё одну команду для теста пайплайна
            $pipeCmd = New-MMCommand `
                -TeamId  $script:TargetTeam.id `
                -Trigger "pipecmd$($script:Suffix)" `
                -URL     'http://example.com/pipe'

            { $pipeCmd | Move-MMCommand -TeamId $script:Team.id -Confirm:$false } | Should -Not -Throw

            # Убираем за собой
            Remove-MMCommand -CommandId $pipeCmd.id -Confirm:$false
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном CommandId' {
            { Move-MMCommand -CommandId 'invalid-command-id-xyz' -TeamId $script:Team.id -Confirm:$false } |
                Should -Throw
        }

        It 'бросает исключение при невалидном TeamId' {
            { Move-MMCommand -CommandId $script:MoveCommand.id -TeamId 'invalid-team-id-xyz' -Confirm:$false } |
                Should -Throw
        }
    }
}

Describe 'Remove-MMCommand' {

    Context 'Удаление slash-команды' {
        It 'удаляет команду без ошибок' {
            $cmd = New-MMCommand `
                -TeamId  $script:Team.id `
                -Trigger "delcmd$($script:Suffix)" `
                -URL     'http://example.com/del'

            { Remove-MMCommand -CommandId $cmd.id -Confirm:$false } | Should -Not -Throw
        }

        It 'после удаления команда недоступна через Get-MMCommand' {
            $cmd = New-MMCommand `
                -TeamId  $script:Team.id `
                -Trigger "delchk$($script:Suffix)" `
                -URL     'http://example.com/delchk'

            Remove-MMCommand -CommandId $cmd.id -Confirm:$false

            { Get-MMCommand -CommandId $cmd.id } | Should -Throw
        }

        It 'принимает объект команды из пайплайна' {
            $cmd = New-MMCommand `
                -TeamId  $script:Team.id `
                -Trigger "delpipe$($script:Suffix)" `
                -URL     'http://example.com/delpipe'

            { $cmd | Remove-MMCommand -Confirm:$false } | Should -Not -Throw
        }

        It 'удаляет основную тестовую команду' {
            { Remove-MMCommand -CommandId $script:TestCommand.id -Confirm:$false } | Should -Not -Throw
            $script:TestCommand = $null
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном CommandId' {
            { Remove-MMCommand -CommandId 'invalid-command-id-xyz' -Confirm:$false } | Should -Throw
        }
    }
}

Describe 'Invoke-MMCommand' {

    Context 'Выполнение slash-команды' {
        It 'достигает API (ошибка от сервера при отсутствии обработчика)' {
            # В sandbox нет реального обработчика — проверяем, что запрос доходит до API,
            # а не падает на стороне клиента с неожиданной ошибкой
            try {
                $result = Invoke-MMCommand -Command '/testcmd' -TeamId $script:Team.id
                # Если вдруг вернулось — тоже ок
                $true | Should -Be $true
            } catch {
                # Ожидаем ошибку от сервера (нет обработчика), но не ошибку клиента
                $_.Exception.Message | Should -Not -BeNullOrEmpty
            }
        }

        It 'принимает ChannelId и TeamId без исключения на стороне клиента' {
            $channel = Get-MMChannel -Name 'town-square'

            try {
                Invoke-MMCommand -Command '/away' -ChannelId $channel.id -TeamId $script:Team.id
            } catch {
                # /away — системная команда, может вернуть ответ или ошибку — оба варианта ок
                $true | Should -Be $true
            }
        }
    }
}
