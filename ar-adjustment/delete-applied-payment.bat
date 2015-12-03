@echo off
REM - File: delete-applied-payment.bat
REM - Description: Makes it easy to remove an applied payment from a charge in 5 Star.
REM - Author: Tommy Goode

: Setup
: call util\loadconfig.bat

: Input
set PaymentTNum=
set /P PaymentTNum=Enter the Payment ID to be deleted:
set ChargeTNum=
set /P ChargeTNum=Enter the Charge ID the payment is applied to:
set PaymentAmount=
set /P PaymentAmount=Enter the amount of the payment:
echo.

: Confirmation
set CusCode=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-cuscode.sql -h -1 -W -v TNum=%PaymentTNum%"') do @set CusCode=%%a

set ChargeOldBalance=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W -v TNum=%ChargeTNum%"') do @set ChargeOldBalance=%%a

echo You want to delete the application of %CusCode%'s %PaymentTNum%, in the amount of $%PaymentAmount%, from %ChargeTNum% (balance %ChargeOldBalance%). Is that correct?
set /P Confirmation=(Y/N)

if /I NOT '%Confirmation%'=='Y' goto Input

: SQL
call util\sqlcmdwrapper.bat -d %DB% -i %~dp0delete-applied-payment.sql -h -1 -W 2>&1

: Conclusion
set ChargeNewBalance=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W -v TNum=%ChargeTNum%"') do @set ChargeNewBalance=%%a
echo New balance for charge %ChargeTNum% is $%ChargeNewBalance%.

pause
