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
function Exit-Script {Write-Host "Canceled Script!" -ForegroundColor Red; Write-Host "`nPress any key to exit:`n"; $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'); exit}
#Checks to see if the path was not found correctly.
if (-not $notfound -and ($userinput -ne "Yes")) {
    
    if ((-not $notfound -and ($userinput -eq "No")) -or ($notfound -and ($userinput -eq "OK"))) {
        #Brings up folder dialog if the path wasn't found correctly
        $FolderDiag = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
            SelectedPath = "${Env:ProgramFiles(x86)}\Steam\"
            Description = 'Select your Steam install directory:'
            ShowNewFolderButton = $false
        }
        $outcome = $FolderDiag.ShowDialog()
        $steaminstallpath = $FolderDiag.SelectedPath
        $FolderDiag.Dispose()
        Remove-Variable "FolderDiag"
        #Executes the Exit-Script function if the user cancels the selection
        if ($outcome -eq "Cancel") {Exit-Script}
    }
    #Executes the Exit-Script function if the user pressed cancel or the exit button
    else {
        Exit-Script
    }
}
#Prepares variable to be reused
$notfound = $false
#Grabs the content of the libraryfolders.vdf file
$applist = Get-Content "$steaminstallpath/config/libraryfolders.vdf" -ErrorVariable 'notfound' -ErrorAction SilentlyContinue
#Executes the Exit-Script function if the script couldn't find the libraryfolders.vdf file
if ($notfound) {Write-Host "Cannot find libraryfolders.vdf! Try to make sure that you selected the correct folder!`n" -ForegroundColor Red; Exit-Script}
#Formats contents and counts how many apps are listed
$applist = (($applist | Select-String "\t\t\t.*") -replace '\t\t\t"([^"]*).*','$1').Split("\n")
$appcount = $applist.Count
#Writes to console to let the user know that it is not recommended to use their computer during this process and to press any key to start
Write-Host "It is not recommended to use your computer during this process, as Steam will be repeatedly gaining focus.`n`nBefore starting this script, make sure that Steam is running/fully updated and all apps have no pending updates.`n`nPress Ctrl + C to cancel at any time (you may have to press a random key afterward for it to register.)" -ForegroundColor Red
Write-Host "`nPress any key to start:"
#Waits for user to press any key
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
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
    Write-Progress -Activity "Validating Steam Library Apps..." -Status "Validating App $app... $percent`% ($currentapp/$appcount)" -PercentComplete $percent -SecondsRemaining -1
    #Starts validation
    Start-Process "Steam://validate/$app"
    #Waits for validation to actually start
    $before = 0
    while ($before -eq 0)
    {
        $before = (Get-WmiObject -Class Win32_Process -Filter {Name = 'steam.exe'}).ReadTransferCount + (Get-WmiObject -Class Win32_Process -Filter {Name = 'steam.exe'}).WriteTransferCount
        Start-Sleep -Milliseconds 100
    }
    #Samples and compares the disk utilization for Steam every 250 milliseconds. When there is no more disk utilization for 1.5 seconds, it assumes the validation is complete and moves on
    $occurrences = 0
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
    #Writes to the console to let the user know of individual app validation
    Write-Host "`tValidated App $app!" -ForegroundColor Magenta
}
#Updates progress display to show that the script has been completed
Write-Progress -Activity "Validating Steam Library Apps..." -Status "Complete!" -PercentComplete 100
#Writes to the console to let the user know that all apps have completed their validation
Write-Host "Done!" -ForegroundColor Green
#Writes to the console to let the user know that Steam will be restarted after key is pressed
Write-Host "Restarting Steam..." -ForegroundColor Cyan
Write-Host "`nPress any key to restart Steam:"
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
#Restarts steam
Start-Process "Steam://exit"
Wait-Process -Name steam
Start-Process -FilePath "$steaminstallpath/steam.exe"
#Writes to the console to let the user know the user that Steam has been restarted
Write-Host "Done!" -ForegroundColor Green
#Writes to the console to let the user know that the script has completely finished.
Write-Host "`nThe script has completed successfully!" -ForegroundColor DarkGreen -BackgroundColor Black
#Writes to the console to let the user know to press any key to exit
Write-Host "`nPress any key to exit:`n"
#Waits for the user to press any key
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
