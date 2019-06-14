
Configuration devMachineConfig
{
  Import-DscResource -Module cChoco
  Import-DscResource -Module PackageManagement -ModuleVersion 1.4.1
  
  Node "localhost"
  {
    LocalConfigurationManager {
      DebugMode = 'ForceModuleImport'
    }
    cChocoInstaller installChoco {
      InstallDir = "c:\choco"
    }
    cChocoPackageInstaller installChrome {
      Name        = "googlechrome"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	  
    cChocoPackageInstaller installvscode {
      Name        = "vscode"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	  
    cChocoPackageInstaller installcmder {
      Name        = "cmder"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	  
    cChocoPackageInstaller installgitkraken {
      Name        = "gitkraken"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	  

    PackageManagementSource PSGallery
    {
        Ensure      = "Present"
        Name        = "psgallery"
        ProviderName= "PowerShellGet"
        SourceLocation   = "https://www.powershellgallery.com/api/v2/"
        InstallationPolicy ="Trusted"
    }
    
    PackageManagement posh-git
    {
      Ensure               = "Present"
      Name                 = "posh-git"
      Source               = "PSGallery"
      DependsOn            = "[PackageManagementSource]PSGallery"
    }

    PackageManagement posh-docker
    {
      Ensure               = "Present"
      Name                 = "posh-docker"
      Source               = "PSGallery"
      DependsOn            = "[PackageManagementSource]PSGallery"
    }
  }
}

devMachineConfig

Start-DscConfiguration .\devMachineConfig -wait -Verbose -force