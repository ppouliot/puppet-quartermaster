ECHO OFF
CLS 
:LOOP
REM This is the menu that appears after WinPE is done loading
REM A B and C deploy an image to the computers hard drive using different rdeploy tags
ECHO Please select one of the following installation options:
ECHO ----------------------------------------------------------------
ECHO A. Windows 2008 Server Basic Installs (x86_64)
ECHO B. Windows 2008 R2 Server Basic Installs (x86_64)
ECHO C. Windows Hyper-V Installations
ECHO D. Misc Useful Tools
ECHO E. Windows Vista Ultimate (x86_64)
ECHO ----------------------------------------------------------------
REM This takes you to a normal command prompt while in WinPE
ECHO Q. Quit
:: SET /P prompts for input and sets the variable
:: to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter: 
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%
ECHO.
:: /I makes the IF comparison case-insensitive
IF /I '%Choice%'=='A' GOTO ItemA
IF /I '%Choice%'=='B' GOTO ItemB
IF /I '%Choice%'=='C' GOTO ItemC
IF /I '%Choice%'=='D' GOTO ItemD
IF /I '%Choice%'=='E' GOTO ItemE
IF /I '%Choice%'=='Q' GOTO End
ECHO "%Choice%" is not valid. Please try again.
ECHO.
GOTO Loop
REM Each letter will run a separate bat file - you don't have to do that you can add the code directly into this file
:ItemA
Q:\sys\menu\w2k8-basic.cmd
GOTO End
:ItemB
Q:\sys\menu\w2k8r2-basic.cmd
GOTO End
:ItemC
Q:\sys\menu\hyper-v.cmd
GOTO End
:ItemD
Q:\sys\menu\tools.cmd
GOTO End
:ItemE
Q:\sys\vista-ultimate.cmd

:Quit
:End
