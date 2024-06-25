::Made By Cater_Maozi
::QQ 3600873229 From China
@echo off
setlocal ENABLEDELAYEDEXPANSION
title Bat Update Sever Test

:head
    ::Here %ip% is Your Server Domain(Please add "http://" or "https://" before the variable)
    set ip=http://127.0.0.1

    set fn=BatUpdateServerTest
    set tempdir=!cd!\!fn!
    ::Detect whether the software direcroty exists
    if not exist "!cd!\!fn!\sendup\firststart.ini" (
      mkdir !fn!
      mkdir !fn!\sendup
      echo true>!fn!\sendup\firststart.ini
      echo First Start
    )

 
:scansystem
    ::Detect whether the system version is Windows 8 or above
    ::The System directory of Windows 8 and below version does not have its own "wget.exe"
    for /f "delims=" %%a in ('powershell -Command "if (Get-Command wget -ErrorAction SilentlyContinue) { Write-Output 'true' } else { Write-Output 'false' }"') do set "systemlevel=%%a"  
 
    if !systemlevel! == true (
      echo System Version High
    ) else (
      echo System Version Low
    )
    ::ver | findstr /i "10." > nul
    ::if !errorlevel! equ 0 (
      ::set systemlevel=true
      ::echo System Version High
    ::) else (
      ::set systemlevel=false
      ::echo System Version Low
    ::)

    ::.. This is my old detection method, and I have replaced it now.
    ::Because my test environment is Windows 11 professional workstation version.I ignored the home version above Windows 8 and did not bring its own "wget" command.


    ::If the system version below Windows 8,Download wget.exe use Powershell
    if !systemlevel! == false (
      if not exist "!tempdir!\tools\wget.exe" (
       mkdir !tempdir!\tools
       PowerShell -Command "(new-object System.Net.WebClient).DownloadFile('%ip%/wget.exe','!tempdir!\tools\wget.exe')"
       )
      rem Detect whether the system environment varibable "WGET_FILE" exists
        if not defined WGET_FILE (
      rem The system environment varibable "WGET_FILE" is not found
          echo Not Found Path WGET_FILE
            set PATHDIR=!tempdir!\tools
            setx WGET_FILE "!PATHDIR!" /m
              if !errorlevel! neq 0 (
      rem Detect whether the script is "run in administrator mode"
                echo [ERROR] Please Use System-Admin^(Administrator^) Permission To Open This Program
                exit
              ) else (
                echo Path Set Successful.^(!WGET_FILE!^)
              )
      rem Set a temporarily availavle variable
      rem Because of the characteristics of Batch,The new system environment variables will only take effect the next time the script is started.
              set wget=!PATHDIR!\wget.exe
        ) else if "!WGET_FILE:~0,1!"=="" (
      rem The system environment varibable "WGET_FILE" is found but it is null
            set PATHDIR=!tempdir!\tools
            setx WGET_FILE "!PATHDIR!" /m
              if !errorlevel! neq 0 (
      rem Detect whether the script is "run in administrator mode"
                echo [ERROR] Please Use System-Admin^(Administrator^) Permission To Open This Program
                exit
              ) else (
                echo Path Set Successful.^(!WGET_FILE!^)
              )
      rem Set a temporarily availavle variable
      rem Because of the characteristics of Batch,The new system environment variables will only take effect the next time the script is started.
           set wget=!PATHDIR!\wget.exe
        ) else (
          echo Path WGET_FILE is Seted.^(!WGET_FILE!^)
      rem I originally wanted to use the PATH environment variable directly to ensure that the "wget" command was directly available
      rem Example:
      rem setx PATH "!PATH!;!WGET_FILE!"
      rem However,using Batch to modify system environment variables,the characters cannot exceed 1024
      rem I have not found a solution at present,mayve my Batch level is to poor. HAHA : )
      rem So I can only change it to this,and then replace the wget command with "wget"
          set wget=!wget_file!\wget.exe
        )
    )

:update
    ::Here is to check the update,you need to build your own server
    cd !tempdir!\sendup
    ::This "updatelist.ini" file is a list of available updates with the following format:
    ::1
    ::2
    ::3
    ::4
    ::...
    if !systemlevel! == false (
      "%wget%" -q %ip%/updatelist.ini
    ) else (
       wget -q %ip%/updatelist.ini
    )
    for /F "tokens=*" %%a in (updatelist.ini) do (
      set "number=%%a"
          rem Check whether the update of this version has been made
          rem This is a statement used to detect whether this update has been performed before
          rem This "if not exist" statement has a bug.
          rem When a .bat already exists,although it has been detected,it will still execute the contents in the brackets behind it
          rem I can't troubleshoot the problem,even if T try to solve it with ChatGPT-4o.
          rem This may be due to the logical error of the Batch language itself,because I think it is a low-level language
          rem But it may also be my own grammar problem,after all my Batch level is too poor. HAHA : )
          rem If you know what caused this error,please come to Github warehouse to submit the Issue,and I will thank you very much for answering my confusion!!
        if exist !tempdir!\sendup\!number!.bat (
          rem Here is download update required(in .bat format),you need to build your own server
          rem You can download other files you need again in the updated .bat file,such as:
          rem This .bat is in "BatUpdateServerTest\sendup" but wget.exe is in "BatUpdateServerTest\tools"
          rem You can change the code format yourself to make it easier.
          rem You can also take the trouble to set the wget path in the updated .bat.Because I am lazy and save trouble,I use the "cd" command directly to the wget.exe directory here(use with caution).Because it may have bugs.
          rem 2.bat(Updated Downloaded)
          rem cd..
          rem cd tools
          rem wget http://127.0.0.1/up/2/MiniWorldGameClient.exe
          rem rename MiniWorldGameClient.exe Minecraft.exe
          rem exit
        ) else (
          set "url=%ip%/up/!number!.bat"
          if !systemlevel! == false (
            "%wget%" -q "!url!"
          ) else (
             wget -q "!url!"
           )
          echo Scan a New Version:!number! 
          echo Starting Update
          rem Use the "call" command to refer to the downloaded .bat for updating
          call "!number!.bat"
        )
    )
    del updatelist.ini
    ::Delete update list .ini file
    

:end
    ::End the script
    ::This is only a demonstration code.
    ::You can write other contents according to your own needs.
    endlocal
    pause
    exit
