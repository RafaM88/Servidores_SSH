@echo off
setlocal

rem Obtener la ruta del directorio donde se encuentra el archivo .bat
set "ScriptDir=%~dp0"

rem Definir la ruta completa del script de PowerShell
set "PowerShellScript=%ScriptDir%scripts\servidores.ps1"

rem Ejecutar el script de PowerShell con bypass a la política de ejecución
powershell -NoProfile -ExecutionPolicy Bypass -File "%PowerShellScript%"

endlocal
