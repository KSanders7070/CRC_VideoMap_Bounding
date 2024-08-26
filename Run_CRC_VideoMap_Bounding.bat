@echo off
setlocal enabledelayedexpansion

rem Navigate to the directory where the batch file is located
cd /d "%~dp0"

set testMode=F
if /i "!testMode!"=="T" (
	set boundingCoords=-84.20559203427143 39.75987383567464 -81.61735880309048 41.46992782488129
	set "inputDir=C:\Users\ksand\OneDrive\Desktop\PROJFOLDER\CRC Video Map Bounding\originalVideoMaps"
	set "outputDir=C:\Users\ksand\OneDrive\Desktop\PROJFOLDER\CRC Video Map Bounding\convertedVideoMaps"
	goto testStart
)

echo.
echo.
echo Running System Checks...
echo.
echo.

rem Check if TWRCab_2_LineString.py exists in the same directory as the .bat file
if not exist "%~dp0CRC_VideoMap_Bounding.py" (
    cls
    echo.
    echo.
    echo                            ---------
    echo                             WARNING
    echo                            ---------
    echo.
    echo "CRC_VideoMap_Bounding.py" is not in the same directory as this .bat file
	echo.
	echo Please download/move CRC_VideoMap_Bounding.py to this directory and restart
	echo this batch file:
	echo %~dp0
	echo.
	echo.
	echo Press any key to exit...
    pause>nul
    exit /b
)

rem Check if PowerShell is installed
powershell -command "exit" >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo.
    echo                            ---------
    echo                             WARNING
    echo                            ---------
    echo.
    echo PowerShell is not installed or not available in the PATH.
	echo This script requires PowerShell to function properly.
	echo.
    echo Press any key to launch the website to download it from and install it.
    echo.
    echo Once complete, launch this batch file again.
    pause>nul
    start https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell
    exit /b
)

rem Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo.
    echo                            ---------
    echo                             WARNING
    echo                            ---------
    echo.
    echo Python 3.0 or higher is required to run this script and I could not find it.
    echo Press any key to launch the website to download it from and install it.
    echo.
    echo Be sure to install it to "PATH" when prompted.
    echo.
    echo Once complete, launch this batch file again.
    pause>nul
    start https://www.python.org/downloads/
    exit /b
)

rem Check if Python version is 3.0 or higher
for /f "tokens=2 delims= " %%a in ('python --version') do set version=%%a
for /f "tokens=1 delims=." %%b in ("%version%") do set major=%%b
if %major% lss 3 (
    cls
    echo.
    echo.
    echo                            ---------
    echo                             WARNING
    echo                            ---------
    echo.
    echo Python 3.0 or higher is required to run this script.
    echo You currently have Python %version% installed.
    echo Press any key to launch the website to download a compatible version.
    echo.
    echo Be sure to install it to "PATH" when prompted.
    echo.
    echo Once complete, launch this batch file again.
    pause>nul
    start https://www.python.org/downloads/
    exit /b
)

rem Check if Shapely and GeoJSON libraries are installed
python -c "import shapely, geojson" >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo                            ---------
    echo                             WARNING
    echo                            ---------
    echo.
    echo The required Python libraries "Shapely and GeoJSON" are not installed.
    echo.
    echo Press any key to install these libraries or close this window to exit...
    pause>nul
	
	echo.
	echo.
	echo Installing Shapely and Geojson libraries, please wait...
	echo.
	echo.
    
    python -m pip install shapely geojson
    
    if %errorlevel% neq 0 (
        echo.
        echo                            ---------
        echo                             WARNING
        echo                            ---------
        echo.
        echo     ... Errors with installation detected.
        echo.
        echo     Please read the errors above and attempt to resolve them
        echo     prior to launching this batch file again.
        echo.
        echo Press any key to exit...
        pause>nul
        exit /b
    )

    rem Recheck if the libraries were installed successfully
    python -c "import shapely, geojson" >nul 2>&1
    if %errorlevel% neq 0 (
        echo.
        echo                            ---------
        echo                             WARNING
        echo                            ---------
        echo.
        echo     ... Libraries still not detected after installation.
        echo         Please check the installation logs above.
        echo.
        echo Press any key to exit...
        pause>nul
        exit /b
    )
)

:defineBoundingBox

cls

rem Prompt user for optional ERAM Defaults to be added

echo.
echo                        ----------------
echo                          BOUNDING BOX
echo                        ----------------                  
echo.
echo      Provide two coordinates that define a Bounding Box.
echo.
echo      All data outside of the box will be removed from
echo      the .geojsons in the exported file.
echo.
echo      Type or paste a list of coordinate sets that define
echo      your Bounding Box separated by commas and no spaces.
echo.
echo      Format: minLon,minLat,maxLon,maxLat
echo.
echo           i.e. SouthWest coordinates and then the
echo                NorthEast coordinates
echo.
echo      Example: -90.0,40.0,-85.0,45.0
echo.
echo.

set /p boundingCoords=Enter bounding box coordinates as described above and press Enter: 

if "!boundingCoords!"=="" (
    echo.
	echo.
    echo ERROR: No input provided.
	echo        Press any key to try again and provide a list of coordinates.
    pause>nul
    goto defineBoundingBox
)

rem Check for invalid characters
echo !boundingCoords! | findstr /r "[^0-9,.-]" >nul
if %errorlevel% neq 0 (
    echo ERROR: Invalid characters detected. Please use only digits, commas, and periods.
    echo        Press any key to try again.
    pause >nul
    exit /b
)

rem Check if the number of coordinates is exactly 4
set count=0
for %%a in (!boundingCoords!) do (
    set /a count+=1
)

if !count! neq 4 (
    echo.
    echo ERROR: You must provide exactly four values ^(two coordinate pairs^).
    echo        Press any key to try again.
    pause>nul
    goto defineBoundingBox
)

:SelectDirectories

rem Ask user to select the input directory

cls

echo.
echo.
echo             ------------------------
echo              SELECT INPUT DIRECTORY
echo             ------------------------
echo.
echo Please select the input directory containing all the
echo .geojson files you want converted.
echo.
echo This script will clip ALL .geojson files contained within
echo your selected directory of data outside the Bounding Box
echo and output them to another file/directory.

set inputDir=
for /f "tokens=*" %%i in ('powershell -command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select the input directory'; if($f.ShowDialog() -eq 'OK'){Write-Host $f.SelectedPath}"') do set inputDir=%%i
if not defined inputDir (
    echo ERROR... No input directory selected. Exiting.
    exit /b
)

cls

rem Ask user to select the output directory

cls

echo.
echo.
echo             -------------------------
echo              SELECT OUTPUT DIRECTORY
echo             -------------------------
echo.
echo Please select the output directory where all clipped
echo .geojson files will be stored.

set outputDir=
for /f "tokens=*" %%i in ('powershell -command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select the output directory'; if($f.ShowDialog() -eq 'OK'){Write-Host $f.SelectedPath}"') do set outputDir=%%i
if not defined outputDir (
    echo No output directory selected. Exiting.
    exit /b
)

:testStart

cls

echo.
echo.
echo                        ----------
echo                         CLIPPING
echo                        ----------
echo.
echo Depending on a few factors, this may take a moment. Please wait...
echo.
echo.

rem Run the python script and pass in the appropriate arguments
python CRC_VideoMap_Bounding.py "!inputDir!" "!outputDir!" "!boundingCoords!"

echo.
echo.
echo.
echo                         ------
echo                          DONE
echo                         ------
echo.
echo Conversion script complete and clipped files saved here:
echo !outputDir!
echo.
echo Please check above for any errors that may have been encountered.
echo.
echo Press any key to exit...
pause>nul
