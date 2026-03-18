BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = $fileConfig.TestTeamName
    }
    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

        Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
    $script:Team = Get-MMTeam -Name $config.TestTeamName
}

Describe 'Get-MMChannel' {

    Context '-All (все каналы системы)' {
        It 'возвращает каналы всех команд' {
            $result = Get-MMChannel -All

            $result          | Should -Not -BeNullOrEmpty
            $result.name     | Should -Contain 'town-square'
        }

        It 'возвращает массив объектов (enumeration работает корректно)' {
            $first = Get-MMChannel -All | Select-Object -First 1

            $first    | Should -Not -BeNullOrEmpty
            $first.id | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Список каналов команды' {
        It 'возвращает каналы команды' {
            $result = Get-MMChannel -TeamId $script:Team.id
            $result | Should -Not -BeNullOrEmpty
        }

        It 'содержит системные каналы town-square и off-topic' {
            $result = Get-MMChannel -TeamId $script:Team.id
            $result.name | Should -Contain 'town-square'
            $result.name | Should -Contain 'off-topic'
        }
    }

    Context '-Name' {
        It 'возвращает канал по имени' {
            $result = Get-MMChannel -TeamId $script:Team.id -Name 'town-square'
            $result.name | Should -Be 'town-square'
            $result.id   | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение если канал не найден' {
            { Get-MMChannel -TeamId $script:Team.id -Name 'nonexistent_channel_xyz' } | Should -Throw
        }
    }

    Context '-ChannelId' {
        It 'возвращает канал по ID' {
            $id     = (Get-MMChannel -TeamId $script:Team.id -Name 'town-square').id
            $result = Get-MMChannel -ChannelId $id
            $result.id   | Should -Be $id
            $result.name | Should -Be 'town-square'
        }

        It 'бросает исключение при невалидном ID' {
            { Get-MMChannel -ChannelId 'invalid-id-xyz' } | Should -Throw
        }
    }

    Context 'Pipeline' {
        It 'принимает ChannelId из пайплайна по имени свойства' {
            $source = Get-MMChannel -TeamId $script:Team.id -Name 'town-square'
            $result = $source | Get-MMChannel
            $result.id | Should -Be $source.id
        }
    }

    Context 'DefaultTeam' {
        BeforeAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force) -DefaultTeam $config.TestTeamName
        }

        AfterAll {
            Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
        }

        It 'возвращает список каналов команды без -TeamId' {
            $result = Get-MMChannel

            $result      | Should -Not -BeNullOrEmpty
            $result.name | Should -Contain 'town-square'
        }

        It 'возвращает канал по имени без -TeamId' {
            $result = Get-MMChannel -Name 'town-square'

            $result.name | Should -Be 'town-square'
        }
    }

    Context '-Filter' {
        It 'возвращает каналы по -eq на name' {
            $result = Get-MMChannel -TeamId $script:Team.id -Filter { $_.name -eq 'town-square' }

            $result      | Should -Not -BeNullOrEmpty
            $result.name | Should -Be 'town-square'
        }

        It 'возвращает каналы по -like на name' {
            $result = Get-MMChannel -TeamId $script:Team.id -Filter { $_.name -like 'town*' }

            $result | Should -Not -BeNullOrEmpty
            ($result | Where-Object { $_.name -like 'town*' }) | Should -Not -BeNullOrEmpty
        }

        It 'фильтрует по type' {
            $result = Get-MMChannel -TeamId $script:Team.id -Filter { $_.type -eq 'O' }

            $result | Should -Not -BeNullOrEmpty
            $result | ForEach-Object { $_.type | Should -Be 'O' }
        }

        It 'возвращает пустой результат при несовпадении' {
            $result = Get-MMChannel -TeamId $script:Team.id -Filter { $_.name -eq 'nonexistent-channel-xyz-abc' }

            $result | Should -BeNullOrEmpty
        }
    }
}
