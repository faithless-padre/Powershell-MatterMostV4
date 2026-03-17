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

    $script:TestUser = Get-MMUser -Username $config.TestUsername

    $script:TempFile = Join-Path ([System.IO.Path]::GetTempPath()) 'mm_msg_attach.txt'
    Set-Content -Path $script:TempFile -Value 'Send-MMMessage attachment test'
}

AfterAll {
    if (Test-Path $script:TempFile) { Remove-Item $script:TempFile -Force }
}

Describe 'Send-MMMessage' {

    Context 'Личное сообщение по username (-ToUser)' {
        It 'отправляет DM и возвращает MMPost' {
            $result = Send-MMMessage -ToUser $script:TestUser.username -Message 'DM by username'

            $result                | Should -Not -BeNullOrEmpty
            $result.message        | Should -Be 'DM by username'
            $result.GetType().Name | Should -Be 'MMPost'
        }
    }

    Context 'Личное сообщение через пайп из MMUser (-ToUserId)' {
        It 'принимает объект MMUser из пайплайна' {
            $result = $script:TestUser | Send-MMMessage -Message 'DM via pipeline'

            $result.message | Should -Be 'DM via pipeline'
        }
    }

    Context 'Групповое сообщение (-ToUsers)' {
        It 'отправляет сообщение в групповой чат' {
            $extra  = New-MMUser -Username "grp_$(Get-Date -Format 'HHmmss')" -Email "grp_$(Get-Date -Format 'HHmmss')@test.com" -Password (ConvertTo-SecureString 'Pester123!' -AsPlainText -Force)
            $result = Send-MMMessage -ToUsers @($script:TestUser.username, $extra.username) -Message 'Group message'

            $result.message | Should -Be 'Group message'

            Remove-MMUser -UserId $extra.id
        }

        It 'бросает исключение если меньше 2 получателей' {
            { Send-MMMessage -ToUsers @($script:TestUser.username) -Message 'test' } |
                Should -Throw
        }
    }

    Context 'Сообщение в канал (-ToChannel)' {
        It 'отправляет сообщение в канал по имени' {
            $result = Send-MMMessage -ToChannel 'town-square' -Message 'Channel message'

            $result.message | Should -Be 'Channel message'
        }

        It 'бросает исключение при несуществующем канале' {
            { Send-MMMessage -ToChannel 'nonexistent-channel-xyz' -Message 'test' } |
                Should -Throw
        }
    }

    Context 'Ответ в тред (-RootId)' {
        It 'отправляет ответ в тред' {
            $root   = Send-MMMessage -ToChannel 'town-square' -Message 'Root post'
            $result = Send-MMMessage -ToChannel 'town-square' -Message 'Thread reply' -RootId $root.id

            $result.root_id | Should -Be $root.id
        }
    }

    Context 'Сообщение с вложением в канал (-ToChannel -FilePath)' {
        It 'отправляет сообщение с файлом в канал' {
            $result = Send-MMMessage -ToChannel 'town-square' -Message 'Channel with attachment' -FilePath $script:TempFile

            $result                | Should -Not -BeNullOrEmpty
            $result.file_ids       | Should -Not -BeNullOrEmpty
            $result.file_ids.Count | Should -Be 1
            $result.GetType().Name | Should -Be 'MMPost'
        }
    }

    Context 'Личное сообщение с вложением (-ToUser -FilePath)' {
        It 'отправляет DM с файлом' {
            $result = Send-MMMessage -ToUser $script:TestUser.username -Message 'DM with attachment' -FilePath $script:TempFile

            $result                | Should -Not -BeNullOrEmpty
            $result.file_ids       | Should -Not -BeNullOrEmpty
            $result.file_ids.Count | Should -Be 1
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при несуществующем пользователе' {
            { Send-MMMessage -ToUser 'nonexistent_user_xyz' -Message 'test' } |
                Should -Throw
        }
    }
}
