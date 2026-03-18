BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json
    $config = @{
        Url                 = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername       = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword       = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName        = $fileConfig.TestTeamName
    }
    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

        Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force)
}

Describe 'Get-MMTeam' {

    Context 'Список всех команд' {
        It 'возвращает хотя бы одну команду без параметров' {
            $result = Get-MMTeam
            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает хотя бы одну команду с -All' {
            $result = Get-MMTeam -All
            $result | Should -Not -BeNullOrEmpty
        }

        It '-All возвращает тот же результат что и без параметров' {
            $withAll    = Get-MMTeam -All
            $withoutAll = Get-MMTeam
            ($withAll | Measure-Object).Count | Should -Be ($withoutAll | Measure-Object).Count
        }
    }

    Context '-Name' {
        It 'возвращает команду по имени' {
            $result = Get-MMTeam -Name $config.TestTeamName
            $result.name | Should -Be $config.TestTeamName
            $result.id   | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение если команда не найдена' {
            { Get-MMTeam -Name 'nonexistent_team_xyz' } | Should -Throw
        }
    }

    Context '-TeamId' {
        It 'возвращает команду по ID' {
            $id     = (Get-MMTeam -Name $config.TestTeamName).id
            $result = Get-MMTeam -TeamId $id
            $result.id   | Should -Be $id
            $result.name | Should -Be $config.TestTeamName
        }

        It 'бросает исключение при невалидном ID' {
            { Get-MMTeam -TeamId 'invalid-id-xyz' } | Should -Throw
        }
    }

    Context 'Pipeline' {
        It 'принимает TeamId из пайплайна по имени свойства' {
            $source = Get-MMTeam -Name $config.TestTeamName
            $result = $source | Get-MMTeam
            $result.id | Should -Be $source.id
        }
    }

    Context '-Filter' {
        It 'возвращает команды по -eq на name' {
            $teamName = $config.TestTeamName
            $result   = Get-MMTeam -Filter { $_.name -eq $teamName }

            $result      | Should -Not -BeNullOrEmpty
            $result.name | Should -Be $config.TestTeamName
        }

        It 'возвращает команды по -like на name' {
            $prefix = $config.TestTeamName.Substring(0, [Math]::Min(3, $config.TestTeamName.Length))
            $result = Get-MMTeam -Filter ([scriptblock]::Create('$_.name -like "' + $prefix + '*"'))

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает пустой результат при несовпадении' {
            $result = Get-MMTeam -Filter { $_.name -eq 'nonexistent-team-xyz-abc' }

            $result | Should -BeNullOrEmpty
        }
    }
}
