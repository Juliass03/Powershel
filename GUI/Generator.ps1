Write-Host "`n============Welcome!=============="
Write-Host "`n  $(Get-Date),hello!  "
Write-Host "`n  $(Get-CimInstance -ClassName Win32_ComputerSystem)"

Add-type -AssemblyName presentationframework, presentationcore

$wpf = @{ }
$x = Split-Path -Parent $MyInvocation.MyCommand.Definition
$path = $x + ".\MainWindow.xaml"

$inputXAML = Get-Content -Path $path
$inputCleanXAML = $inputXAML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace 'x:Class=".*?"','' -replace 'd:DesignHeight="\d*?"','' -replace 'd:DesignWidth="\d*?"',''


[xml]$xaml = $inputCleanXAML
Write-Host "  Xaml file load successfully!"
$reader = New-Object System.Xml.XmlNodeReader $xaml
$tempform = [Windows.Markup.XamlReader]::Load($reader)
Write-Host "  Windows Form Creates Successfully!"

$namedNodes = $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")
$namedNodes | ForEach-Object {$wpf.Add($_.Name, $tempform.FindName($_.Name))}




$wpf.Cancel.add_Click({
    exit
})





function Show-OpenFileDialog
{
  param
  (
    $StartFolder = [Environment]::GetFolderPath('MyDocuments'),

    $Title = 'Open what?',

    $Filter = 'RapidModule|*.mod'
  )




  $dialog = New-Object -TypeName Microsoft.Win32.OpenFileDialog


  $dialog.Title = $Title
  $dialog.InitialDirectory = $StartFolder
  $dialog.Filter = $Filter


  $resultat = $dialog.ShowDialog()
  if ($resultat -eq $true)
  {
    $wpf.TextBox.Text = $dialog.FileName
  }
}

$wpf.More.add_Click({
    Show-OpenFileDialog -Title "Choose your rapid module" 
})





$wpf.Confirm.add_Click({
    $rapidfile = Get-Content -Path $wpf.TextBox.Text
    Write-Host "  Load" $wpf.TextBox.Text  "..."
    $ArrayPres = @()
    foreach($rapidline in $rapidfile){
        if(($rapidline -cmatch "PERS *")){
            $Splitlist = -split $rapidline
            if($Splitlist[0] -cmatch "PERS"){
                $props = @{ Name = $Splitlist[2].Trim(";").Trim(":=");Type = $Splitlist[1]}
                $ArrayPres += (New-Object pscustomobject -prop $props)
            }
            else{
                Write-Host $rapidline "not match..."
            }
        }
        else{
            Write-Host $rapidline "not match..."
        }
        
    }
    $ArrayPres | Export-Csv "PresValues.csv" -NoTypeInformation
    Write-Host "  PresValues.csv had been exported. Check it for fix if error. "


})






Write-Host "  Dialog Showing!"
Write-Host "  ================================="
Write-Host "  Choose your rapid module file!"
$wpf.MainWindow.ShowDialog() | Out-Null

