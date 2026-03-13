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
    $script:AdminUser = Get-MMUser -Username $config.AdminUsername
}

Describe 'Get-MMUserAudit' {

    Context 'Получение аудита' {
        It 'возвращает записи аудита без ошибок' {
            $result = Get-MMUserAudit -UserId $script:AdminUser.id
            $result | Should -Not -BeNullOrEmpty
        }

        It 'записи содержат обязательные поля' {
            $entry = Get-MMUserAudit -UserId $script:AdminUser.id | Select-Object -First 1
            $entry.user_id    | Should -Be $script:AdminUser.id
            $entry.create_at  | Should -BeGreaterThan 0
        }

        It 'принимает объект пользователя из пайплайна' {
            $result = $script:AdminUser | Get-MMUserAudit
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { Get-MMUserAudit -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }
}
