Import-Module PSMermaidTools
import-module powershell-yaml

# Which foldes
$companies = @("company_a", "company_b")

foreach ($company in $companies) {
  
  # Read YAML files
  $teams = Get-Content -Raw "$($company)/teams.yml"
  $teamsObject = ConvertFrom-YAML $teams

  $domains = Get-Content -Raw "$($company)/domains.yml"
  $domainsObject = ConvertFrom-YAML $domains

  $techStack = Get-Content -Raw "$($company)/tech-stack.yml"
  $techStackObject = ConvertFrom-YAML $techStack

  # Create output folder
  $path = "output/$($company)" 
  if ((Test-Path -Path $path) -eq $false) {
    New-Item -Path $path -ItemType Directory  | Out-Null
  }

  # Generate Diagram

  $diagram = New-MermaidDiagram -C4Component

  foreach ($domain in $domainsObject) {
    $domainContainer = New-MermaidC4ContainerBoundary -Name $domain.name -Key $domain.name
    $diagram | Add-MermaidC4ContainerBoundary $domainContainer

    foreach ($team in $teamsObject.where{ ($_.domain -eq $domain.name) }) {
      $component = New-MermaidC4Component -Name $team.name -Key $team.name
      Add-MermaidC4Component -Component $component -Boundary $domainContainer
    }
  }

  $mermaidString = $diagram | ConvertTo-MermaidString 
  
  # Generate HTML
  $html = Get-Content "scripts/template.html"
  $replaced = $html.replace("#{replace}#", $mermaidString)
  $replaced | Out-File -FilePath "output/$($company)/teams_$(get-date -f yyyy-MM-dd).html"
}
