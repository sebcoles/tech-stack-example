# Which foldes
$companies = @("company_a","company_b")

foreach($company in $companies) {

# Read YAML files
$teams = Get-Content -Raw "$($company)/teams.yml"
$teamsObject = ConvertFrom-YAML $teams

$domains = Get-Content -Raw "$($company)/domains.yml"
$domainsObject = ConvertFrom-YAML $domains

$techStack = Get-Content -Raw "$($company)/tech-stack.yml"
$techStackObject = ConvertFrom-YAML $techStack

# Create output folder
$path = "output/$($company)" 
if((Test-Path -Path $path) -eq $false){
  New-Item -Path $path -ItemType Directory  | Out-Null
}

# Generate Diagram
  $diagram = New-MermaidDiagram -C4Component
  $group = New-MermaidC4ContainerBoundary -Name $company -Key $company
  $diagram | Add-MermaidC4ContainerBoundary $group
  
  foreach ($domain in $domainsObject)
  {
    $component = New-MermaidC4Component -Name $domain.name -Key $domain.name
    Add-MermaidC4Component -Component $component -Boundary $group

    foreach($data_push in $domain.pushes_data_to){
      $diagram | Add-MermaidC4Relation -From $domain.name -To $data_push -Label "pushes data to"
    }

    foreach($data_pull in $domain.pulls_data_from){
        $diagram | Add-MermaidC4Relation -From $data_pull -To $domain.name -Label "pulls data from"
    }
  }

  $mermaidString = $diagram | ConvertTo-MermaidString 
  
  # Generate HTML
  $html = Get-Content .\template.html
  $replaced = $html.replace("#{replace}#", $mermaidString)
  $replaced | Out-File -FilePath "output/$($company)/domains_$(get-date -f yyyy-MM-dd).html"
}

