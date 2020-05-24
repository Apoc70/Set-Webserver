# Set-Webserver.ps1

Configures Internet Information Server (IIS) log file settings

## Description

This script reconfigures the IIS log folder to target a different folder besides the default C:\inetpub\logs folder. Additionally the log settings can be adjusted as well.

The script changes the default log file location and settings on a server level. By default the settings are inherited by websites. If manual changes have been made on a webite level, not all settings will be inherited.

## Parameters

### LogFolderPath

New IIS log folder path, i.e. D:\IISLogs. Default is an empty string. 

### LogFilePeriod

Log file period (interval), Hourly|Daily|Weekly|Monthly|MaxSize
MaxSize configuration not yet implemented

### LocalTimeRollover

Boolean parameter indicating, if the local time shall be used for filenames and rollover
Default $FALSE

## Examples

``` PowerShell
.\Set-Webserver.ps1 -LogFolderPath D:\IISLogs
```

Change the IIS log file location to D:\IISLogs

``` PowerShell
.\Set-Webserver.ps1 -LogFilePeriod Hourly
```

Change the IIS log period to an hourly period

``` PowerShell
.\Set-Webserver.ps1 -LocalTimeRollover $true
```

Use the local time for filenames and log file rollover

## Note
THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE
RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

## Credits

Written by: Thomas Stensitzki

## Stay connected

- My Blog: [http://justcantgetenough.granikos.eu](http://justcantgetenough.granikos.eu)
- Twitter: [https://twitter.com/stensitzki](https://twitter.com/stensitzki)
- LinkedIn: [http://de.linkedin.com/in/thomasstensitzki](http://de.linkedin.com/in/thomasstensitzki)
- Github: [https://github.com/Apoc70](https://github.com/Apoc70)
- MVP Blog: [https://blogs.msmvps.com/thomastechtalk/](https://blogs.msmvps.com/thomastechtalk/)
- Tech Talk YouTube Channel (DE): [http://techtalk.granikos.eu](http://techtalk.granikos.eu)

For more Office 365, Cloud Security, and Exchange Server stuff checkout services provided by Granikos

- Blog: [http://blog.granikos.eu](http://blog.granikos.eu)
- Website: [https://www.granikos.eu/en/](https://www.granikos.eu/en/)
- Twitter: [https://twitter.com/granikos_de](https://twitter.com/granikos_de)

## Additional Credits

- Some parts (c) Michel de Rooij, michel@eightwone.com