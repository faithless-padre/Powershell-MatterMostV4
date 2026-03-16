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
    $script:Admin    = Get-MMUser -Me
    $script:User2    = Get-MMUser -Username $config.TestUsername
    $script:TestPass = ConvertTo-SecureString 'Pester123!' -AsPlainText -Force
}

Describe 'New-MMDirectChannel' {

    Context 'Создание DM канала' {
        It 'создаёт канал прямых сообщений' {
            $result = New-MMDirectChannel -UserId1 $script:Admin.id -UserId2 $script:User2.id

            $result      | Should -Not -BeNullOrEmpty
            $result.type | Should -Be 'D'
        }

        It 'принимает объект пользователя из пайплайна' {
            $result = $script:Admin | New-MMDirectChannel -UserId2 $script:User2.id

            $result      | Should -Not -BeNullOrEmpty
            $result.type | Should -Be 'D'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { New-MMDirectChannel -UserId1 $script:Admin.id -UserId2 'invalid-id' } |
                Should -Throw
        }
    }
}

Describe 'New-MMGroupChannel' {

    Context 'Создание группового канала' {
        It 'создаёт групповой канал для нескольких пользователей' {
            $user3  = New-MMUser -Username "gm_$($script:Suffix)" -Email "gm_$($script:Suffix)@test.com" -Password $script:TestPass
            $result = New-MMGroupChannel -UserIds @($script:Admin.id, $script:User2.id, $user3.id)

            $result      | Should -Not -BeNullOrEmpty
            $result.type | Should -Be 'G'

            Remove-MMUser -UserId $user3.id
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при менее чем 3 пользователях' {
            { New-MMGroupChannel -UserIds @($script:Admin.id, $script:User2.id) } |
                Should -Throw
        }
    }
}

Describe 'Get-MMChannelMembers' {

    Context 'Список участников' {
        It 'возвращает участников канала' {
            $channel = Get-MMChannel -Name 'town-square'
            $result  = Get-MMChannelMembers -ChannelId $channel.id

            $result               | Should -Not -BeNullOrEmpty
            $result[0].user_id    | Should -Not -BeNullOrEmpty
            $result[0].channel_id | Should -Be $channel.id
        }

        It 'принимает объект канала из пайплайна' {
            $result = Get-MMChannel -Name 'town-square' | Get-MMChannelMembers

            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Get-MMChannelMembers -ChannelId 'invalid-id' } |
                Should -Throw
        }
    }
}

Describe 'Set-MMChannelPrivacy' {

    Context 'Изменение приватности' {
        It 'переключает публичный канал в приватный' {
            $channel = New-MMChannel -Name "priv_$($script:Suffix)" -DisplayName "Privacy Test $($script:Suffix)"
            $result  = Set-MMChannelPrivacy -ChannelId $channel.id -Privacy Private

            $result      | Should -Not -BeNullOrEmpty
            $result.type | Should -Be 'P'
        }

        It 'переключает приватный канал обратно в публичный' {
            $channel = New-MMChannel -Name "pub_$($script:Suffix)" -DisplayName "Pub Test $($script:Suffix)" -Type Private
            $result  = Set-MMChannelPrivacy -ChannelId $channel.id -Privacy Public

            $result.type | Should -Be 'O'
        }

        It 'принимает объект канала из пайплайна' {
            $channel = New-MMChannel -Name "pipe_$($script:Suffix)" -DisplayName "Pipe Test $($script:Suffix)"
            $result  = $channel | Set-MMChannelPrivacy -Privacy Private

            $result.type | Should -Be 'P'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Set-MMChannelPrivacy -ChannelId 'invalid-id' -Privacy Private } |
                Should -Throw
        }
    }
}

Describe 'Restore-MMChannel' {

    Context 'Восстановление канала' {
        It 'восстанавливает удалённый канал' {
            $channel = New-MMChannel -Name "restore_$($script:Suffix)" -DisplayName "Restore Test $($script:Suffix)"
            Remove-MMChannel -ChannelId $channel.id
            $result = Restore-MMChannel -ChannelId $channel.id

            $result           | Should -Not -BeNullOrEmpty
            $result.delete_at | Should -Be 0
        }

        It 'принимает объект канала из пайплайна' {
            $channel = New-MMChannel -Name "restpipe_$($script:Suffix)" -DisplayName "RestPipe $($script:Suffix)"
            Remove-MMChannel -ChannelId $channel.id
            $result = $channel | Restore-MMChannel

            $result.delete_at | Should -Be 0
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Restore-MMChannel -ChannelId 'invalid-id' } |
                Should -Throw
        }
    }
}
