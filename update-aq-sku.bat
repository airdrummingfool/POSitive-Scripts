@echo off
REM - File: update-aq-sku.bat
REM - Description: Runs a SQL script that updates the set AQ SKU
REM - Author: Tommy Goode

set DB=IRD_MASTER

: Enter Primary SKU of item
set PrimarySKU=null
set /p PrimarySKU="Enter Primary SKU of item: "
echo.

set INVNO=null
for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -Q "SET NOCOUNT ON; SELECT TOP 1 BAR_INVNO FROM BARCODES WHERE BAR_ID = 1 AND BAR_BARCODE='%PrimarySKU%';" -h -1 -W') do @set INVNO=%%a
IF "%INVNO%" == "null" (echo Couldn't find item! && PAUSE && exit /b)

set DESC=null
for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -Q "SET NOCOUNT ON; SELECT TOP 1 BAR_DESCRIPTION FROM BARCODES WHERE BAR_ID = 1 AND BAR_INVNO='%INVNO%';" -h -1 -W') do @set DESC=%%a

set CurrentAQSKU=null
for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-aqsku.sql -h -1 -W') do @set CurrentAQSKU=%%a
IF "%CurrentAQSKU%" == "null" (set CurrentAQSKU=empty)

set VendorSKU=null
for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-vendorsku.sql -h -1 -W') do @set VendorSKU=%%a
IF "%VendorSKU%" == "null" (set VendorSKU=empty)

set VendorID=null
for /f "usebackq delims=" %%a in (`call sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-vendorid.sql -h -1 -W`) do @set VendorID=%%a
IF "%VendorID%" == "null" (set VendorID=empty)

echo You are about to update %PrimarySKU%: %DESC% (INVNO is %INVNO%)
echo Current AQ SKU is %CurrentAQSKU%
echo Recommended AQ SKU is %VendorSKU%@%VendorID%

set NewAQSKU=null
set /p NewAQSKU="Enter new AQ SKU (leave empty to use recommended): "
IF "%NewAQSKU%" == "null" (echo Using recommended... && set NewAQSKU=%VendorSKU%@%VendorID%)

call sqlcmdwrapper.bat -d %DB% -i update-aq-sku\update-aq-sku.sql -h -1 -W -v INVNO="%INVNO%" NewAQSKU="%NewAQSKU%"

set NewAQSKU=null
for /f "delims=" %%a in ('call sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-aqsku.sql -h -1 -W') do @set NewAQSKU=%%a
echo New AQ SKU is %NewAQSKU%

echo.
PAUSE
