@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM =====================================
REM 1. CREATE ALIAS FOR CMD/POWERSHELL
REM =====================================
SET "ALIAS_NAME=omni_preview"
SET "ALIAS_FOLDER=C:\NEXINA\Misc\Alias"

REM Get the folder of this installer (where OmniPreview.exe is located)
SET "INSTALLER_DIR=%~dp0"

REM Create alias folder if it doesn't exist
IF NOT EXIST "%ALIAS_FOLDER%" mkdir "%ALIAS_FOLDER%"

REM Path to the wrapper batch file
SET "WRAPPER_FILE=%ALIAS_FOLDER%\%ALIAS_NAME%.bat"

REM Create the wrapper batch file pointing to the installer folder
(
    ECHO @echo off
    ECHO "%INSTALLER_DIR%OmniPreview.exe" %%*
) > "%WRAPPER_FILE%"

REM Add alias folder to user PATH permanently if not already in PATH
FOR /F "tokens=2*" %%A IN ('reg query "HKCU\Environment" /v PATH 2^>nul') DO SET "OLD_PATH=%%B"
ECHO %OLD_PATH% | FIND /I "%ALIAS_FOLDER%" >nul
IF ERRORLEVEL 1 (
    SETX PATH "%OLD_PATH%;%ALIAS_FOLDER%" >nul
)

REM =====================================
REM 2. REGISTER APP FOR OPEN WITH
REM =====================================
SET "APP_EXE=OmniPreview.exe"
SET "APP_PATH=%INSTALLER_DIR%%APP_EXE%"

REM List of extensions to register
SET "EXTS=pdf docx xlsx pptx jpg jpeg png gif bmp svg webp txt md json xml html css js ts py zip mp3 mp4 mkv avi"

REM Register the application itself
REG ADD "HKCU\Software\Classes\Applications\%APP_EXE%" /f >nul
REG ADD "HKCU\Software\Classes\Applications\%APP_EXE%" /v FriendlyAppName /d "Preview" /f >nul
REG ADD "HKCU\Software\Classes\Applications\%APP_EXE%\shell\open\command" /ve /d "\"%APP_PATH%\" \"%%1\"" /f >nul

REM Register per-extension ProgIDs
FOR %%E IN (%EXTS%) DO (
    SET "PROGID=Preview.%%E"

    REG ADD "HKCU\Software\Classes\!PROGID!" /ve /d "Preview (%%E)" /f >nul
    REG ADD "HKCU\Software\Classes\!PROGID!\DefaultIcon" /ve /d "\"%APP_PATH%\",0" /f >nul
    REG ADD "HKCU\Software\Classes\!PROGID!\shell\open\command" /ve /d "\"%APP_PATH%\" \"%%1\"" /f >nul

    REG ADD "HKCU\Software\Classes\.%%E\OpenWithProgids" /v "!PROGID!" /t REG_NONE /f >nul
)

REM Silent success message (can be removed for fully silent)
REM echo ✅ Alias and Open With registration complete.
ENDLOCAL
EXIT /B 0
