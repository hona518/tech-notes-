@echo off
chcp 65001 >nul
rem 显式调用系统自带 PowerShell，避免 PATH 里混进其它版本
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\notes-tool.ps1"
echo.
pause
