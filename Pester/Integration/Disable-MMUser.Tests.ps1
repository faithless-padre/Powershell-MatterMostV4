BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)

    $suffix = (Get-Date -Format 'HHmmss')
    $script:TestUser = New-MMUser `
        -Username  "disabletest_$suffix" `
        -Email     "disabletest_$suffix@test.local" `
        -Password  (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) `
        -FirstName 'Disable' `
        -LastName  'Test'
}

AfterAll {
    if ($script:TestUser) {
        Remove-MMUser -UserId $script:TestUser.id
    }
}

Describe 'Disable-MMUser' {

    Context 'Деактивация' {
        It 'деактивирует пользователя без ошибок' {
            { Disable-MMUser -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'пользователь деактивирован (delete_at > 0)' {
            $user = Get-MMUser -UserId $script:TestUser.id
            $user.delete_at | Should -BeGreaterThan 0
        }

        It 'принимает объект пользователя из пайплайна' {
            # Сначала включаем обратно
            Enable-MMUser -UserId $script:TestUser.id
            { $script:TestUser | Disable-MMUser } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Disable-MMUser -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }
}
