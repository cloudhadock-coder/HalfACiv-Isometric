@echo off
cd /d "%~dp0"
for %%G in ("tools\godot\Godot*_win64.exe") do start "HalfACiv Isometric" "%%~G" --path "%~dp0."
