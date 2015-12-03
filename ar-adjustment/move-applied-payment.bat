@echo off
REM - File: move-applied-payment.bat
REM - Description: Makes it easy to move an applied payment to another charge in 5 Star.
REM - Author: Tommy Goode

: Setup
: call util\loadconfig.bat

: Input
set PaymentTNum=
set /P PaymentTNum=Enter the Payment ID:
set OldChargeTNum=
set /P OldChargeTNum=Enter the Charge ID the payment is currently applied to:
set NewChargeTNum=
set /P NewChargeTNum=Enter the Charge ID the payment should be moved to:

: Confirmation
set CusCode=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-cuscode.sql -h -1 -W -v TNum=%PaymentTNum%"') do @set CusCode=%%a

set PaymentAmount=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0paymenttnum-chargetnum-to-applied-amount.sql -h -1 -W -v ChargeTNum=%OldChargeTNum%"') do @set PaymentAmount=%%a

set OldChargeBalance=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W -v TNum=%OldChargeTNum%"') do @set OldChargeBalance=%%a

set NewChargeBalance=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W -v TNum=%NewChargeTNum%"') do @set NewChargeBalance=%%a

echo "You want to move the application of %CusCode%'s %PaymentTNum%, in the amount of $%PaymentAmount%, from %OldChargeTNum% (balance %OldChargeBalance%) to %NewChargeTNum% (balance %NewChargeBalance%). Is that correct?"
set /P Confirmation=(Y/N)

if /I NOT '%Confirmation%'=='Y' goto Input

: SQL
call util\sqlcmdwrapper.bat -d %DB% -i %~dp0move-applied-payment.sql -h -1 -W 2>&1

: Conclusion
set NewChargeNewBalance=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W -v TNum=%NewChargeTNum%"') do @set NewChargeNewBalance=%%a
echo New balance for charge %NewChargeTNum% is $%NewChargeNewBalance%.

pause
