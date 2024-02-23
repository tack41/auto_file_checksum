@ECHO OFF
echo %date% %time%
echo GoogleDriveの同期を開始します
robocopy G:\ D:\GoogleDrive\ /MIR /XD temp /R:0 /LOG:”D:\sync_google_drive.log” /NP /NDL
echo GoogleDriveの同期が終了しました。
echo %date% %time%

echo OneDriveの同期を開始します
robocopy C:\Users\takashi\OneDrive\ D:\OneDrive\ /MIR /XD temp /R:0 /LOG:”D:\sync_onedrive.log” /NP /NDL
echo OneDriveの同期が完了しました。
echo %date% %time%

pause