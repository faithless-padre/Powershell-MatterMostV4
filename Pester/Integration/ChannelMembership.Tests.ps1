BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = $fileConfig.TestTeamName
    }
    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
    $script:Suffix  = (Get-Date -Format 'HHmmss')
    $script:Team    = Get-MMTeam -Name $config.TestTeamName
    $script:Channel = New-MMChannel -TeamId $script:Team.id -Name "memch_$($script:Suffix)" -DisplayName 'Membership Test Channel'

    # Создаём тестового пользователя
    $script:TestUser = New-MMUser `
        -Username  "memuser_$($script:Suffix)" `
        -Email     "memuser_$($script:Suffix)@test.local" `
        -Password  (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) `
        -FirstName 'Mem' `
        -LastName  'User'

    # Добавляем пользователя в команду, иначе нельзя добавить в канал
    Add-MMUserToTeam -TeamId $script:Team.id -UserId $script:TestUser.id | Out-Null
}

AfterAll {
    if ($script:Channel) {
        Invoke-MMRequest -Endpoint "channels/$($script:Channel.id)" -Method DELETE | Out-Null
    }
    if ($script:TestUser) {
        Invoke-MMRequest -Endpoint "users/$($script:TestUser.id)" -Method DELETE | Out-Null
    }
}

Describe 'Add-MMUserToChannel' {

    Context 'Добавление участника' {
        It 'добавляет пользователя в канал без ошибок' {
            { Add-MMUserToChannel -ChannelId $script:Channel.id -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'пользователь присутствует в каналах после добавления' {
            $channels = Get-MMUserChannels -UserId $script:TestUser.id -TeamId $script:Team.id
            $channels.id | Should -Contain $script:Channel.id
        }

        It 'принимает объект пользователя из пайплайна' {
            $chan2 = New-MMChannel -TeamId $script:Team.id -Name "pip_$($script:Suffix)" -DisplayName 'Pipeline Member Chan'
            try {
                { $script:TestUser | Add-MMUserToChannel -ChannelId $chan2.id } | Should -Not -Throw
            } finally {
                Invoke-MMRequest -Endpoint "channels/$($chan2.id)" -Method DELETE | Out-Null
            }
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Add-MMUserToChannel -ChannelId 'invalid-id-xyz' -UserId $script:TestUser.id } | Should -Throw
        }
    }
}

Describe 'Get-MMUserChannels' {

    Context 'Получение каналов' {
        It 'возвращает список каналов пользователя' {
            $channels = Get-MMUserChannels -UserId $script:TestUser.id -TeamId $script:Team.id
            $channels | Should -Not -BeNullOrEmpty
        }

        It 'возвращает канал, в который пользователь добавлен' {
            $channels = Get-MMUserChannels -UserId $script:TestUser.id -TeamId $script:Team.id
            $channels.id | Should -Contain $script:Channel.id
        }

        It 'принимает объект пользователя из пайплайна' {
            $channels = $script:TestUser | Get-MMUserChannels -TeamId $script:Team.id
            $channels | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Remove-MMUserFromChannel' {

    Context 'Удаление участника' {
        It 'удаляет пользователя из канала без ошибок' {
            { Remove-MMUserFromChannel -ChannelId $script:Channel.id -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'пользователь отсутствует в канале после удаления' {
            $channels = Get-MMUserChannels -UserId $script:TestUser.id -TeamId $script:Team.id
            $channels.id | Should -Not -Contain $script:Channel.id
        }

        It 'принимает объект пользователя из пайплайна' {
            Add-MMUserToChannel -ChannelId $script:Channel.id -UserId $script:TestUser.id | Out-Null
            { $script:TestUser | Remove-MMUserFromChannel -ChannelId $script:Channel.id } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Remove-MMUserFromChannel -ChannelId 'invalid-id-xyz' -UserId $script:TestUser.id } | Should -Throw
        }
    }
}
