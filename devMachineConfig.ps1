
Configuration devMachineConfig
{
  Import-DscResource -ModuleName cChoco -ModuleVersion 2.4.0.0
  Import-DscResource -ModuleName  PackageManagement -ModuleVersion 1.4.1
  
  Node "localhost"
  {
    # Fix issue with MaxEnvelopeSize https://github.com/PowerShell/SharePointDsc/wiki/Error-Exceeded-the-configured-MaxEnvelopeSize-quota
    Script ScriptExample {
      SetScript  = {
        Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 2048
      }
      TestScript = { (Get-Item WSMan:\localhost\MaxEnvelopeSizeKb).Value -eq 2048 }
      GetScript  = { @{ Result = ((Get-Item WSMan:\localhost\MaxEnvelopeSizeKb).Value) } }
    }

    LocalConfigurationManager {
      DebugMode = 'ForceModuleImport'
    }
    cChocoInstaller installChoco {
      InstallDir = "c:\choco"
    }

    cChocoPackageInstallerSet tools {
      Ensure    = 'Present'
      Name      = @(
        "git"
        "googlechrome"
        "vscode"
        "cmder"
        "gitkraken"
        "fiddler"
        "microsoft-teams"
        "docker-desktop"
        "gpg4win"
        "keybase"
        "terraform"
        "windirstat"
        "azure-cli"
        "kubernetes-cli"
        "msbuild-structured-log-viewer"
      ) 
      DependsOn = "[cChocoInstaller]installChoco"
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

Start-DscConfiguration .\devMachineConfig -Wait -Verbose -Force