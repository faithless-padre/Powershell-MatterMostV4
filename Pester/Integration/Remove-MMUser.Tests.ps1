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
    $script:Suffix   = (Get-Date -Format 'HHmmss')
    $script:TestPass = ConvertTo-SecureString 'Pester123!' -AsPlainText -Force
}

Describe 'Remove-MMUser и Enable-MMUser' {

    Context 'Деактивация' {
        BeforeAll {
            $script:User = New-MMUser `
                -Username "rmtest_$($script:Suffix)" `
                -Email    "rmtest_$($script:Suffix)@test.local" `
                -Password $script:TestPass
        }

        It 'деактивирует пользователя' {
            { Remove-MMUser -UserId $script:User.id } | Should -Not -Throw
        }

        It 'деактивированный пользователь имеет delete_at > 0' {
            $user = Get-MMUser -UserId $script:User.id
            $user.delete_at | Should -BeGreaterThan 0
        }

        It 'принимает объект из пайплайна' {
            $pipeUser = New-MMUser `
                -Username "rmpipe_$($script:Suffix)" `
                -Email    "rmpipe_$($script:Suffix)@test.local" `
                -Password $script:TestPass

            { $pipeUser | Remove-MMUser } | Should -Not -Throw
        }
    }

    Context 'Активация' {
        BeforeAll {
            $script:DisabledUser = New-MMUser `
                -Username "entest_$($script:Suffix)" `
                -Email    "entest_$($script:Suffix)@test.local" `
                -Password $script:TestPass
            Remove-MMUser -UserId $script:DisabledUser.id
        }

        It 'активирует деактивированного пользователя' {
            { Enable-MMUser -UserId $script:DisabledUser.id } | Should -Not -Throw
        }

        It 'после активации delete_at равен 0' {
            Enable-MMUser -UserId $script:DisabledUser.id
            $user = Get-MMUser -UserId $script:DisabledUser.id
            $user.delete_at | Should -Be 0
        }
    }

    Context 'Ошибки' {
        It 'Remove-MMUser бросает исключение при невалидном ID' {
            { Remove-MMUser -UserId 'invalid-id-xyz' } | Should -Throw
        }

        It 'Enable-MMUser бросает исключение при невалидном ID' {
            { Enable-MMUser -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }
}
