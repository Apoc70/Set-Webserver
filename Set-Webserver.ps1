<#
  .SYNOPSIS
  Configures IIS log file settings
   
  Thomas Stensitzki
	
  THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
  RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	
  Version 1.1, 2016-07-28

  Ideas, comments and suggestions to support@granikos.eu

  Some parts (c) Michel de Rooij, michel@eightwone.com

  .LINK 
  http://www.granikos.eu/en/scripts

    	
  .DESCRIPTION
  This script reconfigures the IIS log folder to target a different folder besides the
  default C:\inetpub\logs folder. Additionally the log settings can be adjusted as well.
  The script changes the default log file location and settings on a server level. By
  default the settings are inherited by websites. If manual changes have been made on 
  a webite level, not all settings will be inherited.
    
  .NOTES
  Requirements
  - Windows Server 2008 R2 SP1, Windows Server 2012 or Windows Server 2012 R2 

    
  Revision History
  --------------------------------------------------------------------------------
  1.0     Initial community release
  1.1     PowerShell hygiene applied, some typo fixes
    
	
  .PARAMETER LogFolderPath 
  New IIS log folder path, i.e. D:\IISLogs. Default is an empty string.  

  .PARAMETER LogFilePeriod
  Log file period (interval), Hourly|Daily|Weekly|Monthly|MaxSize
  MaxSize configuration not yet implemented

  .PARAMETER LocalTimeRollover
  Boolean parameter indicating, if the local time shall be used for filenames and rollover
  Default $FALSE
	 
  .EXAMPLE
  Change the IIS log file location to D:\IISLogs
  .\Set-Webserver.ps1 -LogFolderPath D:\IISLogs 

  .EXAMPLE
  Change the IIS log period to an hourly period
  .\Set-Webserver.ps1 -LogFilePeriod Hourly

  .EXAMPLE 
  Use the local time for filenames and log file rollover
  .\Set-Webserver.ps1 -LocalTimeRollover $true

#>


Param(
    [parameter(Position=0,Mandatory=$false,ValueFromPipeline=$false,HelpMessage='New IIS log folder path, i.e. D:\IISLogs')]
    [string]$LogFolderPath = '',
    [parameter(Position=1,Mandatory=$false,ValueFromPipeline=$false,HelpMessage='Log file period (Hourly|Daily|Weekly|Monthly|MaxSize)')]
    [string]$LogFilePeriod = '',
    [parameter(Position=2,Mandatory=$false,ValueFromPipeline=$false,HelpMessage='$true/$false indicating, if the local time shall be used for filenames and rollover')]
    [bool]$LocalTimeRollover=$false
)

process{

    # log file property settings
    $lfpDirectory = 'directory'
    $lfpPeriod = 'period'
    $lfpLocalTimeRollover = 'localTimeRollover'
    
    # Check if folder exists, otherwise create folder
    function Create-Folder
    {
       param
       (
         [string]
         $folderPath
       )

        Write-Verbose "Evaluating IIS folder path: $folderPath"

        if(-not ($folderPath -eq ''))
        {
            if(-not (Test-Path $folderPath))
            {
	            Write-Host "Creating IIS log folder path: $folderPath"

                New-Item -Path $folderPath -ItemType directory | Out-Null
            }
	        else
	        {
	            Write-Host "Folder $folderPath already exsists"
	        }
        }
    }

    # Change IIS log file setting
    function ChangeIisLogSetting
    {
       param
       (
         [string]
         $settingName,

         [string]
         $settingValue
       )

        try
        {
            Write-Verbose "Configuring IIS log setting $settingsName to value $settingsValue"

            $logConfig = @{$settingName=$settingValue}
            
            Set-WebConfigurationProperty 'system.applicationHost/sites/siteDefaults' -Name logFile -Value $logConfig           
        }
        catch [system.exception]
        {
            Write-Host 'An error occured while trying to write IIS settings. Please check permissions of your account and ensure that PowerShell is running from an elevated prompt.' -ForegroundColor Red
        }
    }

    # Change IIS default log location and other IIS log settings
    function ChangeIisLogPath
    {
       param
       (
         [string]
         $folderPath
       )

 	    Write-Verbose "IIS Log Folder Path to configure: $folderPath"
 	    Write-Host "Configuring IIS default log location to '$folderPath'"

        if(Test-Path $folderPath)
        {
            ChangeIisLogSetting $lfpDirectory $folderPath
        }
        else
        {
            Write-Host "New IIS log folder $folderPath does not exist. IIS log file folder configuration has not been changed" -ForegroundColor Red
        }
    }

    # Change IIS log period
    function ChangeIisLogPeriod
    {
       param
       (
         [string]
         $logPeriod
       )

        if($AllowedLogFilePeriod -contains $logPeriod)
        {
            Write-Verbose "Changing IIS log periog to: $logPeriod"

            ChangeIisLogSetting $lfpPeriod $logPeriod            
        }
    }

    # Change IIS LocalTimeRollover setting
    function ChangeLocalTimeRollover
    {
       param
       (
         [bool]
         $logLocalTimeRollover
       )

        Write-Verbose "Changing IIS log local time rollover to: $logLocalTimeRollover"

        ChangeIisLogSetting $lfpLocalTimeRollover $logLocalTimeRollover
    }


    function CheckWindowsFeature
    {
       param
       (
         [string]
         $MajorOSVersion
       )

        $featureInstalled = $false        
        
        If ($MajorOSVersion -eq '6.1') 
        {
            Import-Module ServerManager
            If(!(Get-Module ServerManager)) 
            {
                Write-Error 'Problem loading ServerManager module'
                Exit 'ServerManager module could not be loaded!'
            }
	    }

        Write-Verbose "Checking, if Windows Feature 'Web-Server' is installed"

        $feature = Get-WindowsFeature Web-Server
        $featureInstalled = [bool]($feature.Installed)
        
        Write-Verbose "Feature 'Web-Server' installed: $featureInstalled"
        
        return( $featureInstalled )
    }

    ## Main 
    Write-Verbose 'Script started'

    $MajorOSVersion= [string](Get-WmiObject Win32_OperatingSystem | Select-Object Version | Select-Object @{n='Major';e={($_.Version.Split('.')[0]+'.'+$_.Version.Split('.')[1])}}).Major
    $AllowedLogFilePeriod = @('Hourly','Daily','Weekly','Monthly') # MaxSize not yet implemented
    
    if( CheckWindowsFeature($MajorOSVersion) )
    {
        
        Write-Verbose 'Configuring IIS log file settings'

        if($LogFolderPath -ne '')
        {
            # Create IIS Log File Folder, independent from server role
            Create-Folder $LogFolderPath

            #Change log file settings
            ChangeIisLogPath $LogFolderPath $LogFilePeriod
        }

        if($LogFilePeriod -ne '')
        {
            ChangeIisLogPeriod $LogFilePeriod            
        }
        
        if($LocalTimeRollover -ne $null)
        {
            ChangeLocalTimeRollover $LocalTimeRollover
        }
    }
    else
    {
        Write-Host 'IIS is currently not installed. Either add the windows feature manually or install Exchange first and adjust the IIS log file location afterwards.' -ForegroundColor Red
    }

    Write-Verbose 'Script ended'
} #Process