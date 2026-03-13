BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestUsername  = if ($env:MM_TEST_USERNAME)  { $env:MM_TEST_USERNAME }  else { $fileConfig.TestUsername }
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
}

Describe 'Get-MMUser' {

    Context '-All' {
        It 'возвращает всех пользователей' {
            $result = Get-MMUser -All

            $result            | Should -Not -BeNullOrEmpty
            $result.username   | Should -Contain $config.AdminUsername
            $result.username   | Should -Contain $config.TestUsername
        }

        It 'возвращает массив объектов (enumeration работает корректно)' {
            $first = Get-MMUser -All | Select-Object -First 1

            $first        | Should -Not -BeNullOrEmpty
            $first.id     | Should -Not -BeNullOrEmpty
            $first.username | Should -Not -BeNullOrEmpty
        }
    }

    Context '-Me' {
        It 'возвращает текущего пользователя' {
            $user = Get-MMUser -Me

            $user.username | Should -Be $config.AdminUsername
            $user.id       | Should -Not -BeNullOrEmpty
        }
    }

    Context '-Username' {
        It 'возвращает пользователя по username' {
            $user = Get-MMUser -Username $config.TestUsername

            $user.username | Should -Be $config.TestUsername
            $user.id       | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение если пользователь не найден' {
            { Get-MMUser -Username 'nonexistent_user_xyz' } | Should -Throw
        }
    }

    Context '-UserId' {
        It 'возвращает пользователя по ID' {
            $id = (Get-MMUser -Username $config.AdminUsername).id
            $user = Get-MMUser -UserId $id

            $user.id       | Should -Be $id
            $user.username | Should -Be $config.AdminUsername
        }

        It 'бросает исключение при невалидном ID' {
            { Get-MMUser -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }

    Context 'Pipeline' {
        It 'принимает UserId из пайплайна по имени свойства' {
            $source = Get-MMUser -Username $config.AdminUsername
            $result = $source | Get-MMUser

            $result.id       | Should -Be $source.id
            $result.username | Should -Be $source.username
        }
    }

    Context '-Filter' {
        It 'находит пользователя по -eq на username' {
            $result = Get-MMUser -Filter { username -eq 'admin' }

            $result.username | Should -Be 'admin'
        }

        It 'находит пользователей по -like на username' {
            $result = Get-MMUser -Filter { username -like 'adm*' }

            $result | Should -Not -BeNullOrEmpty
            $result.username | Should -BeLike 'adm*'
        }

        It 'исключает пользователя по -ne на username' {
            $result = Get-MMUser -Filter { username -ne 'admin' }

            $result | Should -Not -BeNullOrEmpty
            $result.username | Should -Not -Contain 'admin'
        }

        It 'бросает исключение при неверном синтаксисе фильтра' {
            { Get-MMUser -Filter { invalid } } | Should -Throw
        }
    }
}
