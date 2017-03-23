set bakdir=D:\Codein

for /f %%c in ('forfiles /P %bakdir% /M *.zip /c "cmd /c dir @path" ^| findstr zip') do set myvar=%%c

set year=%myvar:~0,8%
set  day=%myvar:~8,10%
set /a day1=0x%day%-1


if %day1% GTR 1 (
forfiles /P %bakdir% /d -%year%01 /c "cmd /c del /f @path"
)

set bakdir=E:\IDCBak\DB
setlocal EnableDelayedExpansion

for /f  %%b in ('forfiles /P %bakdir% /c "cmd /c echo @path"') do (
for /f %%i in ('forfiles /P %%b /c "cmd /c echo @path"') do (
for /f %%c in ('forfiles /P %%i /M *.bak /c "cmd /c dir @path" ^| findstr bak') do set myvar=%%c

set year=!myvar:~0,8!!
set day=!myvar:~8,10!
set /a day1=!day!-1

if !day1! equ 0 (
exit ) else (
forfiles /P %%i /d -!year!!day1! /c "cmd /c del /f @path"
)
)
)
