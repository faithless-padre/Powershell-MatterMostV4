BeforeAll {
    $config = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $mmUrl = if ($env:MM_URL) { $env:MM_URL } else { $config.Url }
    $adminUser = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $config.AdminUsername }
    $adminPass = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $config.AdminPassword }

    $securePass = ConvertTo-SecureString $adminPass -AsPlainText -Force
    Connect-MMServer -Url $mmUrl -Username $adminUser -Password $securePass

    # Уникальный суффикс для изоляции тестов
    $script:Suffix = (Get-Date -Format 'HHmmss')
    $script:TestPass = ConvertTo-SecureString 'Pester123!' -AsPlainText -Force
}

Describe 'New-MMUser' {

    Context 'Базовое создание' {
        BeforeAll {
            $script:NewUser = New-MMUser `
                -Username "pester_$($script:Suffix)" `
                -Email    "pester_$($script:Suffix)@test.local" `
                -Password $script:TestPass
        }

        It 'возвращает объект пользователя' {
            $script:NewUser          | Should -Not -BeNullOrEmpty
            $script:NewUser.id       | Should -Not -BeNullOrEmpty
            $script:NewUser.username | Should -Be "pester_$($script:Suffix)"
        }

        It 'пользователь доступен через Get-MMUser' {
            $found = Get-MMUser -Username "pester_$($script:Suffix)"
            $found.id | Should -Be $script:NewUser.id
        }
    }

    Context 'С опциональными полями' {
        BeforeAll {
            $script:FullUser = New-MMUser `
                -Username  "pester_full_$($script:Suffix)" `
                -Email     "pester_full_$($script:Suffix)@test.local" `
                -Password  $script:TestPass `
                -FirstName 'Pester' `
                -LastName  'Test' `
                -Nickname  'PT'
        }

        It 'сохраняет FirstName и LastName' {
            $script:FullUser.first_name | Should -Be 'Pester'
            $script:FullUser.last_name  | Should -Be 'Test'
        }

        It 'сохраняет Nickname' {
            $script:FullUser.nickname | Should -Be 'PT'
        }
    }

    Context 'Pipeline' {
        It 'принимает массив объектов по пайплайну' {
            $users = @(
                [PSCustomObject]@{ Username = "pipe1_$($script:Suffix)"; Email = "pipe1_$($script:Suffix)@test.local"; Password = $script:TestPass }
                [PSCustomObject]@{ Username = "pipe2_$($script:Suffix)"; Email = "pipe2_$($script:Suffix)@test.local"; Password = $script:TestPass }
            )

            $created = $users | New-MMUser

            $created.Count          | Should -Be 2
            $created[0].username    | Should -Be "pipe1_$($script:Suffix)"
            $created[1].username    | Should -Be "pipe2_$($script:Suffix)"
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при дублирующемся username' {
            {
                New-MMUser `
                    -Username "pester_$($script:Suffix)" `
                    -Email    "another_$($script:Suffix)@test.local" `
                    -Password $script:TestPass
            } | Should -Throw
        }
    }
}
