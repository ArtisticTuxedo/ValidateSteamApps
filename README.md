# ValidateSteamApps
## Description:
I made this script as a way to automatically validate all Steam apps on any Windows 10/11 computer. This script is great for people who have had some kind of problem with their hard drives and are looking for a way to make sure that all games/apps are working properly. I have not tested this script on Windows 8.1 or older, so it might not work for those operating systems.
## Important information to know before using:
 - This script may take a long time if there are a lot of apps installed.
 - The Steam install directory is the folder where Steam.exe is installed, not where your apps are installed.
 - It is not recommended to use your computer during this process, as Steam will be repeatedly gaining focus. This will make it difficult to do tasks on your computer, especially typing and playing video games.
 - Make sure that Steam is running/updated, has no pending app updates, and has the `Schedule auto-updates` option turned off in the download settings. You can turn this option back on once the script has finished.
 - After downloading the script, the browser will probably initiate a warning, which can be ignored.
 - Steam will restart at the end of the script.

## How to use:
1. Right-click on the script file (.ps1) and press `Run with PowerShell`.
    * The computer may pop up a warning, which can be bypassed by pressing `Open`.
2. The script should launch. It will first try to find the location of the Steam install directory through Registry entries. One of two things will occur:
	* If the script finds the Steam install directory, it will pop up a confirmation box which will list the found directory.
		* If the directory is correct (capitalization doesn't matter) press `Yes` and **skip to step 4** in these instructions.
		* If the directory is incorrect press `No` and continue through these instructions normally.
	* If the script cannot find the Steam install directory, it will pop up a message box saying that you need to select the folder manually. Press "OK" to continue. Carry on in these instructions normally.
3. A dialog box should pop up to allow selecting the folder manually. Choose the folder where Steam.exe is installed and press `OK`.
    - It will try to automatically select `C:\Program Files (x86)\Steam` if it exists since it's the default Steam install directory.
4. A message should appear in the console with some important information. Most of it is already contained in the [Important information section of these instructions](#important-information-to-know-before-using). One thing from the message to remember is that pressing `Ctrl + C` will cancel the script if needed (you may have to press a random key afterward for it to register.) *Press any key* to start the script.
    - If, instead, a message appears saying that the script failed to find the `libraryfolders.vdf` file, you may have selected the wrong folder in **step 3**. Exit the script by pressing any key and restart the script.
        - The Steam install directory is usually `C:\Program Files (x86)\Steam` by default.
5. The script will start automatically validating Steam apps and will show the progress in a few ways:
    * a progress bar showing how many apps have been validated out of the total amount of apps.
    * messages in the console listing which apps have been validated.
6. Once all apps have been validated, Steam will be restarted.
7. The script will finish. To exit, *press any key*.
### I hope this script proves to be useful and makes validating apps easier!
