@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM =====================================
REM 1. REMOVE APPLICATION REGISTRATION (Open With)
REM =====================================
SET "APP_EXE=OmniPreview.exe"

REM Extensions to unregister (must match register script)
SET "EXTS=pdf docx xlsx pptx jpg jpeg png gif bmp svg webp txt md json xml html css js ts py zip mp3 mp4 mkv avi"

REM Delete application registration
REG DELETE "HKCU\Software\Classes\Applications\%APP_EXE%" /f >nul 2>&1

REM Delete per-extension ProgIDs and OpenWith entries
FOR %%E IN (%EXTS%) DO (
    SET "PROGID=Preview.%%E"
    REG DELETE "HKCU\Software\Classes\.%%E\OpenWithProgids" /v "!PROGID!" /f >nul 2>&1
    REG DELETE "HKCU\Software\Classes\!PROGID!" /f >nul 2>&1
)

REM Restart Explorer to clear cache (silent)
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

REM =====================================
REM 2. REMOVE CMD/POWERSHELL ALIAS
REM    (REMOVE PATH ONLY IF FOLDER EMPTY)
REM =====================================
SETLOCAL ENABLEDELAYEDEXPANSION

SET "ALIAS_NAME=omni_preview"
SET "ALIAS_FOLDER=C:\NEXINA\Misc\Alias"
SET "WRAPPER_FILE=%ALIAS_FOLDER%\%ALIAS_NAME%.bat"

REM -------------------------------------
REM Delete the alias batch file
REM -------------------------------------
IF EXIST "%WRAPPER_FILE%" (
    DEL /f /q "%WRAPPER_FILE%" >nul 2>&1
)

REM -------------------------------------
REM Check if alias folder exists
REM -------------------------------------
IF NOT EXIST "%ALIAS_FOLDER%" GOTO :END

REM -------------------------------------
REM Check if alias folder is empty (includes hidden/system files)
REM -------------------------------------
SET "IS_EMPTY=1"
FOR /F %%F IN ('DIR /A /B "%ALIAS_FOLDER%" 2^>nul') DO SET "IS_EMPTY=0"

IF "%IS_EMPTY%"=="0" GOTO :END

REM -------------------------------------
REM Folder exists AND is empty → safe to remove PATH
REM -------------------------------------
FOR /F "usebackq delims=" %%P IN (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PATH','User')"`) DO (
    SET "OLD_PATH=%%P"
)

IF "!OLD_PATH!"=="" GOTO :REMOVE_FOLDER

SET "NEW_PATH=!OLD_PATH:%ALIAS_FOLDER%;=!"
SET "NEW_PATH=!NEW_PATH:;%ALIAS_FOLDER%=!"
SET "NEW_PATH=!NEW_PATH:%ALIAS_FOLDER%=!"

powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('PATH','!NEW_PATH!','User')"

:REMOVE_FOLDER
REM -------------------------------------
REM Remove alias folder itself
REM -------------------------------------
RD "%ALIAS_FOLDER%" 2>nul

:END
ENDLOCAL
EXIT /B 0