BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)

    # Сохраняем оригинальные permissions чтобы восстановить после теста
    $script:OriginalRole = Get-MMRole -Name 'team_user'
    $script:OriginalPermissions = $script:OriginalRole.permissions
}

AfterAll {
    # Восстанавливаем оригинальные permissions
    if ($script:OriginalRole -and $script:OriginalPermissions) {
        Set-MMRole -RoleId $script:OriginalRole.id -Permissions $script:OriginalPermissions | Out-Null
    }
}

Describe 'Set-MMRole' {

    Context 'Изменение permissions' {
        It 'обновляет permissions роли' {
            $role = Get-MMRole -Name 'team_user'
            $newPerms = $role.permissions | Where-Object { $_ -ne 'create_post' }

            Set-MMRole -RoleId $role.id -Permissions $newPerms

            $updated = Get-MMRole -RoleId $role.id
            $updated.permissions | Should -Not -Contain 'create_post'
        }

        It 'возвращает обновлённый объект роли' {
            $role   = Get-MMRole -Name 'team_user'
            $result = Set-MMRole -RoleId $role.id -Permissions $role.permissions

            $result      | Should -Not -BeNullOrEmpty
            $result.id   | Should -Be $role.id
            $result.name | Should -Be 'team_user'
        }
    }

    Context 'Pipeline' {
        It 'принимает объект роли из пайплайна' {
            $role = Get-MMRole -Name 'team_user'
            { $role | Set-MMRole -Permissions $role.permissions } | Should -Not -Throw
        }
    }

    Context 'Сырые данные через -Properties' {
        It 'обновляет permissions через -Properties' {
            $role   = Get-MMRole -Name 'team_user'
            $result = Set-MMRole -RoleId $role.id -Properties @{ permissions = $role.permissions }
            $result.id | Should -Be $role.id
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном RoleId' {
            { Set-MMRole -RoleId 'invalidroleid000' -Permissions @('create_post') } | Should -Throw
        }
    }
}
