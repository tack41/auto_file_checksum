@ECHO OFF
powershell %~dp0\auto_file_checksum.ps1 -DebugOn %* 2> %~dp0\result.log