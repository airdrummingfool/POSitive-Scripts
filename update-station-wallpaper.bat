@echo off
REM - File: update-station-wallpaper.bat
REM - Description: Runs a SQL script that updates all stations' wallpaper settings
REM - Author: Tommy Goode
REM - Copyright 2014 International Restaurant Distributors, Inc.

call util\loadconfig.bat

set "DB=%1"
set "WallpaperPath=%~2"
set "DisplayStyle=%3"
if "%3" == "" goto NOARGS

goto READY

:NOARGS
set DB=%positive_db%

:FILENAME
set WallpaperPath=null
echo Enter full path to wallpaper file (this path must work for all stations!)
set /p "WallpaperPath=Path: "
:# remove quotes if they exist in the path
for /f "useback tokens=*" %%a in ('%WallpaperPath%') do set WallpaperPath=%%~a
echo.

:# make sure wallpaper file exists
echo Entered wallpaper path: %WallpaperPath%
if not exist "%WallpaperPath%" echo Could not find file && goto FILENAME

:DISPLAY_STYLE
set DisplayStyle=null
set DisplayStylePretty=null
set /p DisplayStyle="Choose wallpaper display style (1=tile, 2=center, 0=keep existing): "

:READY
2>NUL CALL :CASE_%DisplayStyle% # jump to :CASE_1, :CASE_2, etc.
IF ERRORLEVEL 1 CALL :DEFAULT_CASE # if case doesn't exist

goto AFTER_CASE

:CASE_1
  set DisplayStylePretty=tile
  GOTO END_CASE
:CASE_tile
  set DisplayStyle=1
  set DisplayStylePretty=tile
  GOTO END_CASE
:CASE_2
  set DisplayStylePretty=center
  GOTO END_CASE
:CASE_center
  set DisplayStyle=2
  set DisplayStylePretty=center
  GOTO END_CASE
:CASE_0
  set DisplayStylePretty=keep
  GOTO END_CASE
:DEFAULT_CASE
  ECHO Unknown display style "%DisplayStyle%"
  set "DisplayStyle=-1"
  GOTO END_CASE

:END_CASE
  VER > NUL # reset ERRORLEVEL
  GOTO :EOF # return from CALL

: AFTER_CASE
if "%DisplayStyle%" == "-1" (GOTO DISPLAY_STYLE)

echo.
echo You are about to update the wallpaper for ALL STATIONS of %DB% to be "%WallpaperPath%"
if not "%DisplayStyle%" == "0" (echo and set the wallpaper display style to %DisplayStylePretty%)
PAUSE

: Do Work
call util\sqlcmdwrapper.bat -d %DB% -i update-station-wallpaper\update-station-wallpaper.sql -h -1 -W -v WallpaperPath="%WallpaperPath%"
if not "%DisplayStyle%" == "0" (call util\sqlcmdwrapper.bat -d %DB% -i update-station-wallpaper\update-station-wallpaper-display-style.sql -h -1 -W -v DisplayStyle="%DisplayStyle%")

echo.
echo done!
