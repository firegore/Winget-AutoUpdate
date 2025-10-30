#Function to get the installed app list, in formatted array

function Get-WingetInstalledApps {

    Param(
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "You MUST supply value for winget repo, we need it")]
        [ValidateNotNullorEmpty()]
        [string]$src
    )
    class Software {
        [string]$Name
        [string]$Id
        [string]$Version
        [string]$AvailableVersion
    }

    #Get list of available packages
    try {
        $installedPackages = get-wingetpackage -Source $src
    }
    catch {
        Write-ToLog "Error while receiving winget package list: $_" "Red"
        $installedPackages = $null
    }

    # Now cycle in real package and split accordingly
    $installedList = @()
    ForEach ($package in $installedPackages) {
        $software = [Software]::new()
        #Manage non latin characters
        $software.Name = $package.Name
        $software.Id = $package.Id
        $software.Version = $package.Version
        $software.AvailableVersion = $package.Available
        #add formatted soft to list
        $installedList += $software
    }

    #If current user is not system, remove system apps from list
    if ($IsSystem -eq $false) {
        $SystemApps = Get-Content -Path "$WorkingDir\config\winget_system_apps.txt" -ErrorAction SilentlyContinue
        $installedList = $installedList | Where-Object { $SystemApps -notcontains $_.Id }
    }

    return $installedList | Sort-Object { Get-Random }



}
