@echo off
REM - File: ar-adjustment.bat
REM - Description: Makes common adjustments in AR.
REM - Author: Tommy Goode

: Setup
call util\loadconfig.bat
set DB=%positive_training_db%

: Menu
echo.
echo Choose from the following options:
echo  1. Recalculate a transaction balance
echo  2. Change the amount of payment/credit applied
echo  3. Move an applied payment/credit to a different charge
echo  Q. Quit
echo.

: Input
set INPUT=
set /P INPUT=

if /I '%INPUT%'=='1' goto Selection1
if /I '%INPUT%'=='2' goto Selection2
if /I '%INPUT%'=='3' goto Selection3
if /I '%INPUT%'=='Q' goto End

goto Menu

: Selection1
echo Recalculate a transaction balance:
call ar-adjustment/recalculate-balance.bat
goto Menu

: Selection2
echo Change the amount of payment/credit applied:

goto Menu

: Selection3
echo Move an applied payment/credit to a different charge:
call ar-adjustment/move-applied-payment.bat
goto Menu

:End
