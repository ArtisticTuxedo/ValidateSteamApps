#Adds in assemblies for the UI
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
#Initializes variable
$steaminstallpath = ""
#Checks registry for Steam install path
$notfound = $true
while ($notfound){
    $steaminstallpath = (Get-ItemProperty -Path HKCU:\SOFTWARE\Valve\Steam -ErrorVariable 'notfound' -ErrorAction Ignore).SteamPath
    if (-not $notfound) {break}
    $steaminstallpath = (Get-ItemProperty -Path HKLM:\SOFTWARE\Valve\Steam -ErrorVariable 'notfound' -ErrorAction Ignore).SteamPath
    break
}
#Initializes variable
$userinput = ""
#Displays pop-up box
if (-not $notfound) {
    $userinput = [System.Windows.MessageBox]::Show("The script has found your Steam install directory! Is this correct?`n`n$steaminstallpath",'Confirmation:','YesNoCancel','Question')
}
else {
    $userinput = [System.Windows.MessageBox]::Show("The script couldn't find your Steam install directory. You will need to select the Steam folder manually.",'Manual input needed:','OKCancel','Exclamation')
}
#Creates function to exit the script
function Exit-Script {Write-Host "Canceled Script!" -ForegroundColor Red; Write-Host "`nPress any key to exit:`n"; [Console]::ReadKey() | Out-Null; exit}
#Checks to see if path was not found.
if (-not $notfound -and ($userinput -ne "Yes")) {
    
    if ((-not $notfound -and ($userinput -eq "No")) -or ($notfound -and ($userinput -eq "OK"))) {
        #Brings up folder dialog if path wasn't found correctly
        $FolderDiag = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
            SelectedPath = "${Env:ProgramFiles(x86)}\Steam\"
            Description = 'Select your Steam install directory:'
            ShowNewFolderButton = $false
        }
        $outcome = $FolderDiag.ShowDialog()
        $steaminstallpath = $FolderDiag.SelectedPath
        $FolderDiag.Dispose()
        Remove-Variable "FolderDiag"
        #Executes the Exit-Script function if user cancels selection
        if ($outcome -eq "Cancel") {Exit-Script}
    }
    #Executes the Exit-Script function if user presses cancel or the exit button
    else {
        Exit-Script
    }
}
#Prepares variable to be reused
$notfound = $false
#Grabs the content of the libraryfolders.vdf file
$applist = Get-Content "$steaminstallpath/config/libraryfolders.vdf" -ErrorVariable 'notfound' -ErrorAction SilentlyContinue
#Executes the Exit-Script function if script couldn't find the libraryfolders.vdf file
if ($notfound) {Write-Host "Cannot find libraryfolders.vdf! Try to make sure that you selected the correct folder!`n" -ForegroundColor Red; Exit-Script}
#Formats contents and counts how many apps are listed
$applist = (($applist | Select-String "\t\t\t.*") -replace '\t\t\t"([^"]*).*','$1').Split("\n")
$appcount = $applist.Count
#Writes to console to let the user know that it is not recommended to use their computer during this process and to press any key to start
Write-Host "It is not recommended to use your computer during this process, as Steam will be repeatedly gaining focus.`n`nBefore starting this script, make sure that Steam is running/fully updated, all apps have no pending updates, and the ""Schedule auto-updates"" option is off in the download settings.`n`nPress Ctrl + C to cancel at anytime (you may have to press a random key afterward for it to register)." -ForegroundColor Red
Write-Host "`nPress any key to start:"
#Waits for user to press any key
[Console]::ReadKey() | Out-Null
#Clears console
Clear-Host
#Writes to console to let the user know that the script is running
Write-Host "`n`n`n`n`n`n`n`nValidating Library..." -ForegroundColor Cyan
#Variables for progress display
$finishedapps = 0
$currentapp = 0
$percent = 0
#Starts validating the apps one by one
foreach ($app in $applist) {
    #Creates and updates progress display
    $currentapp++
    Write-Progress -Activity "Validating Steam Library Apps..." -Status "Validating App $app... ($currentapp/$appcount)" -PercentComplete $percent -SecondsRemaining -1
    #Starts validation
    Start-Process "Steam://validate/$app"
    #Samples and compares the disk utilization for Steam every 250 milliseconds. When there is no more disk utilization for 1.5 seconds, it assumes the validation is complete and moves on
    $occurrences = 0
    $before = 0
    $after = 0
    while ($occurrences -ne 6) {
        $before = (Get-WmiObject -Class Win32_Process -Filter {Name = 'steam.exe'}).ReadTransferCount + (Get-WmiObject -Class Win32_Process -Filter {Name = 'steam.exe'}).WriteTransferCount
        Start-Sleep -Milliseconds 250
        $after = (Get-WmiObject -Class Win32_Process -Filter {Name = 'steam.exe'}).ReadTransferCount + (Get-WmiObject -Class Win32_Process -Filter {Name = 'steam.exe'}).WriteTransferCount
        if (($after - $before) -eq 0) {
            $occurrences++
        }
        else {
            $occurrences = 0
        }
    }
    #Calculates the percentage for the progress display
    $finishedapps++
    $percent = [math]::Floor(([decimal] $finishedapps/$appcount)*100)
    #Writes to console to let the user know of individual app validation
    Write-Host "`tValidated App $app!" -ForegroundColor Magenta
}
#Updates progress display to show that the script has been completed
Write-Progress -Activity "Validating Steam Library Apps..." -Status "Complete!" -PercentComplete 100
#Writes to console to let the user know that all apps have completed their validation
Write-Host "Done!" -ForegroundColor Green
#Writes to console to let the user know that Steam is being restarted
Write-Host "Restarting Steam..." -ForegroundColor Cyan
#Restarts steam
Stop-Process -Name steam
Wait-Process -Name steam
Start-Process -FilePath ($steaminstallpath + "/steam.exe")
#Writes to console to let the user know user that steam has been restarted
Write-Host "Done!" -ForegroundColor Green
#Writes to console to let the user know to press any key to exit
Write-Host "`nPress any key to exit:`n"
#Waits for user to press any key
[Console]::ReadKey() | Out-Null