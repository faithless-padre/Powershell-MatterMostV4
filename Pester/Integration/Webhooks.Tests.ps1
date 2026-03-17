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

    $script:Channel = Get-MMChannel -Name 'town-square'
    $script:Team    = Get-MMTeam -Name $config.TestTeamName
}

Describe 'Get-MMIncomingWebhook / New-MMIncomingWebhook' {

    Context 'Создание incoming webhook' {
        It 'создаёт webhook и возвращает MMIncomingWebhook объект' {
            $result = New-MMIncomingWebhook -ChannelId $script:Channel.id -DisplayName 'Pester Incoming Hook'

            $result                | Should -Not -BeNullOrEmpty
            $result.id             | Should -Not -BeNullOrEmpty
            $result.channel_id     | Should -Be $script:Channel.id
            $result.display_name   | Should -Be 'Pester Incoming Hook'
            $result.GetType().Name | Should -Be 'MMIncomingWebhook'

            $script:IncomingHook = $result
        }

        It 'создаёт webhook по ChannelName' {
            $result = New-MMIncomingWebhook -ChannelName 'town-square' -DisplayName 'Pester Incoming ByName'

            $result.channel_id     | Should -Be $script:Channel.id
            $result.GetType().Name | Should -Be 'MMIncomingWebhook'

            # Удаляем сразу, он нам не нужен дальше
            Remove-MMIncomingWebhook -HookId $result.id
        }

        It 'создаёт webhook через пайплайн канала' {
            $result = $script:Channel | New-MMIncomingWebhook -DisplayName 'Pester Incoming Pipeline'

            $result.channel_id | Should -Be $script:Channel.id

            Remove-MMIncomingWebhook -HookId $result.id
        }
    }

    Context 'Получение incoming webhook' {
        It 'возвращает webhook по ID' {
            $result = Get-MMIncomingWebhook -HookId $script:IncomingHook.id

            $result.id             | Should -Be $script:IncomingHook.id
            $result.GetType().Name | Should -Be 'MMIncomingWebhook'
        }

        It 'возвращает список webhooks по TeamId' {
            $result = Get-MMIncomingWebhook -TeamId $script:Team.id

            $result | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMIncomingWebhook'
        }

        It 'возвращает список webhooks по TeamName' {
            $result = Get-MMIncomingWebhook -TeamName $script:Team.name

            $result | Should -Not -BeNullOrEmpty
        }

        It 'принимает объект MMTeam из пайплайна' {
            $result = $script:Team | Get-MMIncomingWebhook

            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки incoming' {
        It 'бросает исключение при невалидном HookId' {
            { Get-MMIncomingWebhook -HookId 'invalid-hook-id' } | Should -Throw
        }
    }
}

Describe 'Set-MMIncomingWebhook' {

    Context 'Обновление incoming webhook' {
        It 'обновляет display_name webhook' {
            $result = Set-MMIncomingWebhook -HookId $script:IncomingHook.id -DisplayName 'Pester Updated Hook' -ChannelId $script:Channel.id

            $result.id           | Should -Be $script:IncomingHook.id
            $result.display_name | Should -Be 'Pester Updated Hook'
            $result.GetType().Name | Should -Be 'MMIncomingWebhook'
        }

        It 'принимает объект MMIncomingWebhook из пайплайна' {
            $result = $script:IncomingHook | Set-MMIncomingWebhook -DisplayName 'Pester Pipeline Update' -ChannelId $script:Channel.id

            $result.display_name | Should -Be 'Pester Pipeline Update'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном HookId' {
            { Set-MMIncomingWebhook -HookId 'invalid-id' -DisplayName 'test' } | Should -Throw
        }
    }
}

Describe 'Remove-MMIncomingWebhook' {

    Context 'Удаление incoming webhook' {
        It 'удаляет webhook без ошибок' {
            { Remove-MMIncomingWebhook -HookId $script:IncomingHook.id } | Should -Not -Throw
        }

        It 'принимает объект из пайплайна' {
            $hook = New-MMIncomingWebhook -ChannelId $script:Channel.id -DisplayName 'Pester Remove Pipeline'
            { $hook | Remove-MMIncomingWebhook } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном HookId' {
            { Remove-MMIncomingWebhook -HookId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Get-MMOutgoingWebhook / New-MMOutgoingWebhook' {

    Context 'Создание outgoing webhook' {
        It 'создаёт webhook и возвращает MMOutgoingWebhook объект' {
            $result = New-MMOutgoingWebhook `
                -TeamId       $script:Team.id `
                -DisplayName  'Pester Outgoing Hook' `
                -TriggerWords @('!pester') `
                -CallbackUrls @('http://localhost:9000/hook')

            $result                | Should -Not -BeNullOrEmpty
            $result.id             | Should -Not -BeNullOrEmpty
            $result.team_id        | Should -Be $script:Team.id
            $result.display_name   | Should -Be 'Pester Outgoing Hook'
            $result.trigger_words  | Should -Contain '!pester'
            $result.GetType().Name | Should -Be 'MMOutgoingWebhook'

            $script:OutgoingHook = $result
        }

        It 'создаёт webhook по TeamName' {
            $result = New-MMOutgoingWebhook `
                -TeamName     $script:Team.name `
                -DisplayName  'Pester Outgoing ByName' `
                -TriggerWords @('!test') `
                -CallbackUrls @('http://localhost:9000/hook')

            $result.team_id        | Should -Be $script:Team.id
            $result.GetType().Name | Should -Be 'MMOutgoingWebhook'

            Remove-MMOutgoingWebhook -HookId $result.id
        }

        It 'создаёт webhook через пайплайн команды' {
            $result = $script:Team | New-MMOutgoingWebhook `
                -DisplayName  'Pester Outgoing Pipeline' `
                -TriggerWords @('!pipe') `
                -CallbackUrls @('http://localhost:9000/hook')

            $result.team_id | Should -Be $script:Team.id

            Remove-MMOutgoingWebhook -HookId $result.id
        }
    }

    Context 'Получение outgoing webhook' {
        It 'возвращает webhook по ID' {
            $result = Get-MMOutgoingWebhook -HookId $script:OutgoingHook.id

            $result.id             | Should -Be $script:OutgoingHook.id
            $result.GetType().Name | Should -Be 'MMOutgoingWebhook'
        }

        It 'возвращает список webhooks по TeamId' {
            $result = Get-MMOutgoingWebhook -TeamId $script:Team.id

            $result | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMOutgoingWebhook'
        }

        It 'принимает объект MMTeam из пайплайна' {
            $result = $script:Team | Get-MMOutgoingWebhook

            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки outgoing' {
        It 'бросает исключение при невалидном HookId' {
            { Get-MMOutgoingWebhook -HookId 'invalid-hook-id' } | Should -Throw
        }
    }
}

Describe 'Set-MMOutgoingWebhook' {

    Context 'Обновление outgoing webhook' {
        It 'обновляет display_name webhook' {
            $result = Set-MMOutgoingWebhook `
                -HookId        $script:OutgoingHook.id `
                -DisplayName   'Pester Updated Outgoing' `
                -CallbackUrls  @('http://localhost:9000/hook') `
                -TriggerWords  @('!pester')

            $result.id           | Should -Be $script:OutgoingHook.id
            $result.display_name | Should -Be 'Pester Updated Outgoing'
            $result.GetType().Name | Should -Be 'MMOutgoingWebhook'
        }

        It 'принимает объект из пайплайна' {
            $result = $script:OutgoingHook | Set-MMOutgoingWebhook `
                -DisplayName   'Pester Pipeline Outgoing' `
                -CallbackUrls  @('http://localhost:9000/hook') `
                -TriggerWords  @('!pester')

            $result.display_name | Should -Be 'Pester Pipeline Outgoing'
        }
    }
}

Describe 'Reset-MMOutgoingWebhookToken' {

    Context 'Регенерация токена' {
        It 'регенерирует токен без ошибок' {
            { Reset-MMOutgoingWebhookToken -HookId $script:OutgoingHook.id } | Should -Not -Throw
        }

        It 'принимает объект из пайплайна' {
            { $script:OutgoingHook | Reset-MMOutgoingWebhookToken } | Should -Not -Throw
        }
    }
}

Describe 'Remove-MMOutgoingWebhook' {

    Context 'Удаление outgoing webhook' {
        It 'удаляет webhook без ошибок' {
            { Remove-MMOutgoingWebhook -HookId $script:OutgoingHook.id } | Should -Not -Throw
        }

        It 'принимает объект из пайплайна' {
            $hook = New-MMOutgoingWebhook `
                -TeamId       $script:Team.id `
                -DisplayName  'Pester Remove Pipeline' `
                -TriggerWords @('!remove') `
                -CallbackUrls @('http://localhost:9000/hook')
            { $hook | Remove-MMOutgoingWebhook } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном HookId' {
            { Remove-MMOutgoingWebhook -HookId 'invalid-id' } | Should -Throw
        }
    }
}
