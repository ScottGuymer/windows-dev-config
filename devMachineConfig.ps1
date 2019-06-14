Install-Module cChoco

Configuration devMachineConfig
{
  Import-DscResource -Module cChoco
   Node "localhost"
   {
      LocalConfigurationManager
      {
          DebugMode = 'ForceModuleImport'
      }
      cChocoInstaller installChoco
      {
        InstallDir = "c:\choco"
      }
      cChocoPackageInstaller installChrome
      {
        Name        = "googlechrome"
        DependsOn   = "[cChocoInstaller]installChoco"
        #This will automatically try to upgrade if available, only if a version is not explicitly specified.
        AutoUpgrade = $True
      }
      cChocoPackageInstallerSet installSomeStuff
      {
         Ensure = 'Present'
         Name = @(
            "git"
            "googlechrome"
            "7zip"
          )
         DependsOn = "[cChocoInstaller]installChoco"
      }
      
   }
}

devMachineConfig

Start-DscConfiguration .\devMachineConfig -wait -Verbose -force