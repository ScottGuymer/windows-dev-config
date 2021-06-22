
Configuration devMachineConfig
{
  Import-DscResource -ModuleName cChoco -ModuleVersion 2.4.0.0
  Import-DscResource -ModuleName PackageManagement -ModuleVersion 1.4.1
  Import-DscResource -ModuleName cGit -ModuleVersion 0.1.1
  Import-DscResource -ModuleName GraniResource -ModuleVersion 3.7.11.0
  
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
        "azure-cli"
        "cloudfoundry-cli"
        "cmder"
        "docker-desktop"
        "fiddler"
        "git"
        "gitkraken"
        "googlechrome"
        "gpg4win"
        "keybase"
        "kubernetes-cli"
        "kubernetes-helm"
        "microsoft-teams"
        "msbuild-structured-log-viewer"
        "nvm"
        "postman"
        "openssl.light"
        "terraform"
        "vscode"
        "windirstat"
        "yarn"
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

    PackageManagement oh-my-posh {
      Ensure    = "Present"
      Name      = "oh-my-posh"
      Source    = "PSGallery"
      DependsOn = "[PackageManagementSource]PSGallery"
    }

    File code {
      Type            = 'Directory'
      DestinationPath = 'C:\code'
      Ensure          = "Present"
    }

    cGitRepository powershellProfile {
      Ensure        = "Present"
      Repository    = "https://github.com/ScottGuymer/powershell-profile.git"
      BaseDirectory = "C:\code\"
      DependsOn     = "[File]code"
    }
    
    $documents = [Environment]::GetFolderPath("MyDocuments")    
    cSymbolicLink windowsPowershellProfileLink {
      Ensure          = "Present"
      SourcePath      = "C:\code\powershell-profile\"
      DestinationPath = "$documents\WindowsPowerShell\"
      DependsOn       = "[cGitRepository]powershellProfile"
    }

    cSymbolicLink powershellProfileLink {
      Ensure          = "Present"
      SourcePath      = "C:\code\powershell-profile\"
      DestinationPath = "$documents\PowerShell\"
      DependsOn       = "[cGitRepository]powershellProfile"
    }
  }
}

devMachineConfig

Start-DscConfiguration .\devMachineConfig -Wait -Verbose -Force