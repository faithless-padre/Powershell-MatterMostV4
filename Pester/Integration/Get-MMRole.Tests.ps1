BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
}

Describe 'Get-MMRole' {

    Context 'Все роли' {
        It 'возвращает список всех ролей' {
            $roles = Get-MMRole -All

            $roles             | Should -Not -BeNullOrEmpty
            $roles.Count       | Should -BeGreaterThan 5
            $roles.name        | Should -Contain 'system_admin'
            $roles.name        | Should -Contain 'system_user'
        }
    }

    Context 'По имени' {
        It 'возвращает роль system_admin' {
            $role = Get-MMRole -Name 'system_admin'

            $role            | Should -Not -BeNullOrEmpty
            $role.name       | Should -Be 'system_admin'
            $role.id         | Should -Not -BeNullOrEmpty
            $role.permissions | Should -Not -BeNullOrEmpty
        }

        It 'возвращает роль system_user' {
            $role = Get-MMRole -Name 'system_user'
            $role.name | Should -Be 'system_user'
        }

        It 'бросает исключение при несуществующем имени' {
            { Get-MMRole -Name 'nonexistent_role_xyz' } | Should -Throw
        }
    }

    Context 'По ID' {
        It 'возвращает роль по ID' {
            $byName = Get-MMRole -Name 'system_admin'
            $byId   = Get-MMRole -RoleId $byName.id

            $byId.id   | Should -Be $byName.id
            $byId.name | Should -Be 'system_admin'
        }

        It 'бросает исключение при невалидном ID' {
            { Get-MMRole -RoleId 'invalidroleid000' } | Should -Throw
        }
    }

    Context 'По списку имён' {
        It 'возвращает несколько ролей' {
            $roles = Get-MMRole -Names 'system_admin', 'system_user', 'team_admin'

            $roles.Count    | Should -Be 3
            $roles.name     | Should -Contain 'system_admin'
            $roles.name     | Should -Contain 'system_user'
            $roles.name     | Should -Contain 'team_admin'
        }
    }
}
