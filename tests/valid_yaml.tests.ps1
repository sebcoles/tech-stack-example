Import-Module powershell-yaml
Import-Module Pester

Describe "Validating all YAML files are valid" {
    It "Testing domains YAML file" {
        $companies = @("company_a", "company_b")
        foreach ($company in $companies) {
            $domains = Get-Content -Raw "$($company)/domains.yml"
            $domainsObject = ConvertFrom-YAML $domains
            $domainsObject.Length | Should Not BeLessThan 0
        }
    }

    It "Testing tech-stack YAML file" { 
        $companies = @("company_a", "company_b")
        foreach ($company in $companies) { 
            $techStack = Get-Content -Raw "$($company)/tech-stack.yml"
            $techStackObject = ConvertFrom-YAML $techStack  
            $techStackObject.Length | Should Not BeLessThan 0
        }
    }

    It "Testing teams YAML file" { 
        $companies = @("company_a", "company_b")
        foreach ($company in $companies) {
            $teams = Get-Content -Raw "$($company)/teams.yml"
            $teamsObject = ConvertFrom-YAML $teams  
            $teamsObject.Length | Should Not BeLessThan 0
        }
    }
}