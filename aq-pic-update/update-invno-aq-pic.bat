@echo off
REM - File: update-invno-aq-pic.bat
REM - Description: Updates POSitive 5 Star item images from AutoQuotes
REM - Author: Tommy Goode
REM - Copyright 2014 International Restaurant Distributors, Inc.

: Setup
call util\loadconfig.bat
set "INVNO=%1"
set "pwd=%~dp0"
set "tmpdir=%pwd%temp"
if not exist "%tmpdir%\" mkdir "%tmpdir%"
del /Q "%tmpdir%\*"
set "tmppng=%tmpdir%\tmp.png"
set "tmpjpg=%tmpdir%\tmp.jpg"
set "tmpthmb=%tmpdir%\tmp_thumb.jpg"

: Fail early
if "%INVNO%" == "" (echo INVNO not set && exit /b)

echo INVNO: %INVNO%

: Convert INVNO to BlobLink
set BlobLink=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %autoquotes_db% -i aq-pic-update\invno-to-bloblink.sql -h -1 -W') do @set BlobLink=%%a
if "%BlobLink%" == "null" (echo Couldn't find BlobLink for INVNO %INVNO% && exit /b)

: pull the blob out, save it as a tmp file
bcp "SELECT TOP 1 Blob from %autoquotes_db%.dbo.Pictures WHERE BlobLink = '%BlobLink%'" QUERYOUT "%tmppng%" -S %instance% -T -f "%pwd%bcp.fmt" -a 50000 > nul

if not exist "%tmppng%" echo Couldn't extract AQ image && exit /b

: convert to jpg
"%imagemagickpath%\convert.exe" "%tmppng%" -background white -flatten "%tmpjpg%"
: create jpeg thumbnail
"%imagemagickpath%\convert.exe" "%tmppng%" -resize 200x200^> -background white -flatten "%tmpthmb%"

: remove tmp png
del "%tmppng%"

: Create or update BINPIC rows
call util\sqlcmdwrapper.bat -d %positive_db% -i aq-pic-update\update-aq-pic.sql -h -1 -W
