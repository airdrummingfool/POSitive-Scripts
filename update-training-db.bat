@echo off
REM - File: update-training-db.bat
REM - Description: Backs up the master db and restores it over the current training db, then calls the station wallpaper update script
REM - Author: Tommy Goode
REM - Copyright 2014 International Restaurant Distributors, Inc.

call util\loadconfig.bat

echo About to update %positive_training_db% with the contents of %positive_db%
echo Please make sure %positive_training_db% is not in use.
pause

set "tmpdir=%~dp0update-training-db\temp"
if not exist "%tmpdir%\" mkdir "%tmpdir%"

call util\sqlcmdwrapper.bat -i update-training-db\update-training-db.sql -h -1 -W -v TEMP_DIR="%tmpdir%" MASTER_DB="%positive_db%" TRAINING_DB="%positive_training_db%"
if errorlevel 1 pause && goto end

del /Q "%tmpdir%\*"
echo.

pause

echo.
call update-station-wallpaper.bat %positive_training_db% "%training_wallpaper%" 0

:end
