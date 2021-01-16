$Month=(Get-Date).ToString("yyyy-MM")

<#$user= "Contoso\sa01.patch"
$pwd = ConvertTo-SecureString -String "P@ssw0rd123" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $pwd
#>

Configuration InstallPatch2016
{
 param([string[]]$MachineName=$(Get-ChildItem env:\computername).value)
 
 Import-DscResource -ModuleName psdesiredstateconfiguration
 Import-DscResource -ModuleName xwindowsupdate

 Node $MachineName
  {
   
   $patches = Get-Content -Path "\\DSCServer\Share\$Month\2016\patchlist.txt"
    
    foreach ($j in $patches)
    {
       $HF = Get-ChildItem -Path "\\DSCServer\Share\$month\2016" -File | Where-Object {$_.Name -like "*$j*"}
        xHotfix "$j"
           {
            ID = "$j"
            Path = "\\DSCServer\Share\$Month\2016\$HF"
            Ensure = 'Present'
            #PsDscRunAsCredential = $cred
           }
     }
    
  }
}



foreach ($i in (Get-ADDomainController -Filter {operatingsystem -like "*2016*"} | select -ExpandProperty name | sort -Descending))
{
InstallPatch2016 -MachineName $i -OutputPath "E:\Share\$Month\2016\InstallPatch2016"
}


Start-DscConfiguration -Path "E:\Share\$Month\2016\InstallPatch2016" -Wait -Verbose -Force

#To Test DSC Configuration:
#Get-ADDomainController -Filter {operatingsystem -like "*2016*"} -Credential $cred | select -ExpandProperty name | sort -Descending | Test-DscConfiguration -Path "E:\Share\$Month\2016\InstallPatch2016\" -Credential $cred
