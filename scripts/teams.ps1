Import-Module PSMermaidTools
import-module powershell-yaml

# Read YAML files
$teams = Get-Content -Raw ../teams.yml
$teamsObject = ConvertFrom-YAML $teams

$domains = Get-Content -Raw ../domains.yml
$domainsObject = ConvertFrom-YAML $domains

$techStack = Get-Content -Raw ../tech-stack.yml
$techStackObject = ConvertFrom-YAML $techStack

# Create output folder
$path = "..\output" 
if((Test-Path -Path $path) -eq $false){
  New-Item -Path $path -ItemType Directory  | Out-Null
}

# Generate Diagram

  $diagram = New-MermaidDiagram -C4Component

  foreach ($domain in $domainsObject)
  {
    $domainContainer = New-MermaidC4ContainerBoundary -Name $domain.name -Key $domain.name
    $diagram | Add-MermaidC4ContainerBoundary $domainContainer

    foreach ($team in $teamsObject.where{($_.domain -eq $domain.name)})
    {
        $component = New-MermaidC4Component -Name $team.name -Key $team.name
        Add-MermaidC4Component -Component $component -Boundary $domainContainer
    }
}

  $mermaidString = $diagram | ConvertTo-MermaidString 
  
  # Generate HTML
  $html = Get-Content .\template.html
  $replaced = $html.replace("#{replace}#", $mermaidString)
  $replaced | Out-File -FilePath "../output/teams_$(get-date -f yyyy-MM-dd).html"

