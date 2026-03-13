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

    # Проверяем поддержку гостевых аккаунтов (требует лицензии Enterprise)
    $suffix = (Get-Date -Format 'HHmmss')
    $script:TestUser = New-MMUser `
        -Username  "guesttest_$suffix" `
        -Email     "guesttest_$suffix@test.local" `
        -Password  (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) `
        -FirstName 'Guest' `
        -LastName  'Test'

    $script:GuestSupported = $false
    try {
        ConvertTo-MMGuestUser -UserId $script:TestUser.id
        $script:GuestSupported = $true
    } catch {
        if ($_ -match '501') { $script:GuestSupported = $false }
        else { throw }
    }
}

AfterAll {
    if ($script:TestUser) {
        if ($script:GuestSupported) { ConvertFrom-MMGuestUser -UserId $script:TestUser.id }
        Remove-MMUser -UserId $script:TestUser.id
    }
}

Describe 'ConvertTo-MMGuestUser' {

    Context 'Понижение до гостя' {
        It 'понижает пользователя без ошибок' -Skip:(-not $script:GuestSupported) {
            { ConvertTo-MMGuestUser -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'пользователь имеет роль guest после понижения' -Skip:(-not $script:GuestSupported) {
            $user = Get-MMUser -UserId $script:TestUser.id
            $user.roles | Should -BeLike '*guest*'
        }

        It 'принимает объект пользователя из пайплайна' -Skip:(-not $script:GuestSupported) {
            ConvertFrom-MMGuestUser -UserId $script:TestUser.id
            { $script:TestUser | ConvertTo-MMGuestUser } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { ConvertTo-MMGuestUser -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }
}

Describe 'ConvertFrom-MMGuestUser' {

    Context 'Повышение до пользователя' {
        It 'повышает гостя без ошибок' -Skip:(-not $script:GuestSupported) {
            { ConvertFrom-MMGuestUser -UserId $script:TestUser.id } | Should -Not -Throw
        }

        It 'пользователь имеет роль system_user после повышения' -Skip:(-not $script:GuestSupported) {
            $user = Get-MMUser -UserId $script:TestUser.id
            $user.roles | Should -BeLike '*system_user*'
        }

        It 'принимает объект пользователя из пайплайна' -Skip:(-not $script:GuestSupported) {
            ConvertTo-MMGuestUser -UserId $script:TestUser.id
            { $script:TestUser | ConvertFrom-MMGuestUser } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном UserId' {
            { ConvertFrom-MMGuestUser -UserId 'invalid-id-xyz' } | Should -Throw
        }
    }
}
