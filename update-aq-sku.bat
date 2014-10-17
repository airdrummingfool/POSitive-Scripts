@echo off
REM - File: update-aq-sku.bat
REM - Description: Runs a SQL script that updates the set AQ SKU
REM - Author: Tommy Goode

set DB=IRD_MASTER

: Enter Primary SKU of item
set /p PrimarySKU="Enter Primary SKU of item: "
echo.

set INVNO=null

for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -Q "SET NOCOUNT ON; SELECT TOP 1 BAR_INVNO FROM BARCODES WHERE BAR_ID = 1 AND BAR_BARCODE='%PrimarySKU%';" -h -1 -W') do @set INVNO=%%a

IF "%INVNO%" == "null" (echo Couldn't find item! && exit /b)

set DESC=null

for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -Q "SET NOCOUNT ON; SELECT TOP 1 BAR_DESCRIPTION FROM BARCODES WHERE BAR_ID = 1 AND BAR_INVNO='%INVNO%';" -h -1 -W') do @set DESC=%%a

set CurrentAQSKU=null

for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -Q "SET NOCOUNT ON; SELECT TOP 1 CASE WHEN BAR_BARCODE='' THEN 'empty' ELSE BAR_BARCODE END FROM BARCODES WHERE BAR_ID = 2 AND BAR_INVNO='%INVNO%';" -h -1 -W') do @set CurrentAQSKU=%%a
IF "%CurrentAQSKU%" == "null" (set CurrentAQSKU=empty)

echo You are about to update %PrimarySKU%: %DESC% (INVNO is %INVNO%)
echo Current AQ SKU is %CurrentAQSKU%
set /p NewAQSKU="Enter new AQ SKU: "

call sqlcmdwrapper.bat -d %DB% -i aq-sku-update.sql -h -1 -W -v INVNO="%INVNO%" NewAQSKU="%NewAQSKU%"

set NewAQSKU=null

for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -Q "SET NOCOUNT ON; SELECT TOP 1 CASE WHEN BAR_BARCODE='' THEN 'empty' ELSE BAR_BARCODE END FROM BARCODES WHERE BAR_ID = 2 AND BAR_INVNO='%INVNO%';" -h -1 -W') do @set NewAQSKU=%%a
echo New AQ SKU is %NewAQSKU%

echo.
PAUSE
