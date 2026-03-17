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

    # Заранее создаём несколько постов чтобы было что читать
    $script:Post1 = Send-MMMessage -ToChannel 'town-square' -Message 'Get-MMMessage test post 1'
    $script:Post2 = Send-MMMessage -ToChannel 'town-square' -Message 'Get-MMMessage test post 2'
    $script:DmPost = Send-MMMessage -ToUser $script:TestUser.username -Message 'Get-MMMessage DM test'
}

Describe 'Get-MMMessage по ID' {

    Context 'Получение по одному ID' {
        It 'возвращает пост по ID и возвращает MMPost' {
            $result = Get-MMMessage -PostId $script:Post1.id

            $result                | Should -Not -BeNullOrEmpty
            $result.id             | Should -Be $script:Post1.id
            $result.message        | Should -Be 'Get-MMMessage test post 1'
            $result.GetType().Name | Should -Be 'MMPost'
        }
    }

    Context 'Получение по массиву ID' {
        It 'возвращает несколько постов по PostIds' {
            $result = Get-MMMessage -PostIds @($script:Post1.id, $script:Post2.id)

            $result       | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
            $ids = $result | Select-Object -ExpandProperty id
            $ids | Should -Contain $script:Post1.id
            $ids | Should -Contain $script:Post2.id
        }
    }

    Context 'Ошибки ById' {
        It 'бросает исключение при невалидном PostId' {
            { Get-MMMessage -PostId 'invalid-post-id' } | Should -Throw
        }
    }
}

Describe 'Get-MMMessage из канала' {

    Context 'Получение из канала по имени (-FromChannel)' {
        It 'возвращает посты из канала и возвращает MMPost' {
            $result = Get-MMMessage -FromChannel 'town-square' -PerPage 10

            $result               | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMPost'
        }

        It 'поддерживает пагинацию' {
            $page0 = Get-MMMessage -FromChannel 'town-square' -Page 0 -PerPage 5
            $page1 = Get-MMMessage -FromChannel 'town-square' -Page 1 -PerPage 5

            $page0[0].id | Should -Not -Be $page1[0].id
        }

        It 'поддерживает Since' {
            $since  = [long]((Get-Date).AddYears(-1) - [datetime]'1970-01-01').TotalMilliseconds
            $result = Get-MMMessage -FromChannel 'town-square' -Since $since -PerPage 5

            $result | Should -Not -BeNullOrEmpty
        }

        It 'поддерживает IncludeDeleted' {
            $result = Get-MMMessage -FromChannel 'town-square' -IncludeDeleted -PerPage 5

            $result | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение при несуществующем канале' {
            { Get-MMMessage -FromChannel 'nonexistent-channel-xyz' } | Should -Throw
        }
    }
}

Describe 'Get-MMMessage из личной переписки' {

    Context 'Личка по username (-FromUser)' {
        It 'возвращает сообщения из DM с пользователем' {
            $result = Get-MMMessage -FromUser $script:TestUser.username -PerPage 10

            $result               | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMPost'

            $messages = $result | Select-Object -ExpandProperty message
            $messages | Should -Contain 'Get-MMMessage DM test'
        }

        It 'поддерживает Since и IncludeDeleted' {
            $since  = [long]((Get-Date).AddYears(-1) - [datetime]'1970-01-01').TotalMilliseconds
            $result = Get-MMMessage -FromUser $script:TestUser.username -Since $since -IncludeDeleted -PerPage 5

            $result | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение при несуществующем пользователе' {
            { Get-MMMessage -FromUser 'nonexistent_user_xyz' } | Should -Throw
        }
    }

    Context 'Личка через пайп из MMUser (-FromUserId)' {
        It 'принимает объект MMUser из пайплайна' {
            $result = $script:TestUser | Get-MMMessage -PerPage 5

            $result | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMPost'
        }

        It 'поддерживает Since и IncludeDeleted через пайп' {
            $since  = [long]((Get-Date).AddYears(-1) - [datetime]'1970-01-01').TotalMilliseconds
            $result = $script:TestUser | Get-MMMessage -Since $since -IncludeDeleted -PerPage 5

            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Get-MMMessage из группового чата' {

    Context 'Групповой чат (-FromUsers)' {
        It 'возвращает сообщения из группового чата' {
            $extra = New-MMUser `
                -Username "gmsg_$(Get-Date -Format 'HHmmss')" `
                -Email    "gmsg_$(Get-Date -Format 'HHmmss')@test.com" `
                -Password (ConvertTo-SecureString 'Pester123!' -AsPlainText -Force)

            Send-MMMessage -ToUsers @($script:TestUser.username, $extra.username) -Message 'Group msg for Get-MMMessage'

            $result = Get-MMMessage -FromUsers @($script:TestUser.username, $extra.username) -PerPage 10

            $result               | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMPost'

            # Since + IncludeDeleted для FromUsers
            $since  = [long]((Get-Date).AddYears(-1) - [datetime]'1970-01-01').TotalMilliseconds
            $result2 = Get-MMMessage -FromUsers @($script:TestUser.username, $extra.username) -Since $since -IncludeDeleted -PerPage 5
            $result2 | Should -Not -BeNullOrEmpty

            Remove-MMUser -UserId $extra.id
        }

        It 'бросает исключение если меньше 2 пользователей' {
            { Get-MMMessage -FromUsers @($script:TestUser.username) } | Should -Throw
        }
    }
}
