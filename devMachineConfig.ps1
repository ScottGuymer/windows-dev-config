
Configuration devMachineConfig
{
  Import-DscResource -Module cChoco
  Import-DscResource -Module PackageManagement -ModuleVersion 1.4.1
  
  Node "localhost"
  {
    # Fix issue with MaxEnvelopeSize https://github.com/PowerShell/SharePointDsc/wiki/Error-Exceeded-the-configured-MaxEnvelopeSize-quota
    Script ScriptExample {
      SetScript  = {
        Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 2048
      }
      TestScript = {  (Get-Item WSMan:\localhost\MaxEnvelopeSizeKb).Value -eq 2048 }
      GetScript  = { @{ Result = ((Get-Item WSMan:\localhost\MaxEnvelopeSizeKb).Value) } }
    }

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
    cChocoPackageInstaller installfiddler {
      Name        = "fiddler"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	 
    cChocoPackageInstaller installmicrosoft-teams {
      Name        = "microsoft-teams"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	  

    cChocoPackageInstaller installdocker-desktop {
      Name        = "docker-desktop"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	  
    cChocoPackageInstaller installgpg4win {
      Name        = "gpg4win"
      DependsOn   = "[cChocoInstaller]installChoco"
      AutoUpgrade = $True
    }	  
    
    PackageManagementSource PSGallery {
      Ensure             = "Present"
      Name               = "psgallery"
      ProviderName       = "PowerShellGet"
      SourceLocation     = "https://www.powershellgallery.com/api/v2/"
      InstallationPolicy = "Trusted"
    }
    
    PackageManagement posh-git {
      Ensure    = "Present"
      Name      = "posh-git"
      Source    = "PSGallery"
      DependsOn = "[PackageManagementSource]PSGallery"
    }

    PackageManagement posh-docker {
      Ensure    = "Present"
      Name      = "posh-docker"
      Source    = "PSGallery"
      DependsOn = "[PackageManagementSource]PSGallery"
    }
  }
}

devMachineConfig

Start-DscConfiguration .\devMachineConfig -wait -Verbose -force