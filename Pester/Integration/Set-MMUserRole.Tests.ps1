BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)

    $script:Suffix   = (Get-Date -Format 'HHmmss')
    $script:TestUser = New-MMUser `
        -Username "roletest_$($script:Suffix)" `
        -Email    "roletest_$($script:Suffix)@test.local" `
        -Password 'Pester123!'
}

AfterAll {
    if ($script:TestUser) {
        Invoke-MMRequest -Endpoint "users/$($script:TestUser.id)" -Method DELETE | Out-Null
    }
}

Describe 'Set-MMUserRole' {

    Context 'Назначение роли' {
        It 'назначает роль system_admin' {
            { Set-MMUserRole -UserId $script:TestUser.id -Roles 'system_admin system_user' } | Should -Not -Throw

            $user = Get-MMUser -UserId $script:TestUser.id
            $user.roles | Should -BeLike '*system_admin*'
        }

        It 'убирает роль admin, оставляет system_user' {
            Set-MMUserRole -UserId $script:TestUser.id -Roles 'system_admin system_user'
            Set-MMUserRole -UserId $script:TestUser.id -Roles 'system_user'

            $user = Get-MMUser -UserId $script:TestUser.id
            $user.roles | Should -Be 'system_user'
        }
    }

    Context 'Pipeline' {
        It 'принимает объект пользователя из пайплайна' {
            { Get-MMUser -UserId $script:TestUser.id | Set-MMUserRole -Roles 'system_admin system_user' } |
                Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Set-MMUserRole -UserId 'invalid-id-xyz' -Roles 'system_user' } | Should -Throw
        }
    }
}
