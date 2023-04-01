Param(
    [Switch]$DebugOn,
    [string]$targetPath
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$scriptPath = $MyInvocation.MyCommand.Path
$currentDir = Split-Path -Parent $scriptPath
$parentDir = Split-Path -Parent $currentDir

$ErrorResult =  New-Object -TypeName "System.Text.StringBuilder"

if($DebugOn){
   Write-Host "Debug: ON" 
}

function SearchDirectory {
    param ($directoryInfo)

    if($DebugOn){Write-Host "Directory: $($directoryInfo.FullName)"}

    foreach($item in Get-ChildItem $directoryInfo){
        if($item -is [System.IO.DirectoryInfo]){
            SearchDirectory($item)
        }else{
            ProcessFile($item)
        }
    }
}

function ProcessFile{
    param($fileInfo)

    if($DebugOn){Write-Host "File: $($fileInfo.Name)"}
    if($fileInfo.Name.EndsWith(".sha256")){
        $sourceFilePath = $fileInfo.FullName.Replace(".sha256","")
        Write-Host "sourceFilePath: $sourceFilePath"
        if(-Not (Test-Path $sourceFilePath)){
            Write-Host "[NG] There is no file corresponding to checksum file: $sourceFile"
            $ErrorResult.Append("[NG] There is no file corresponding to checksum file: $sourceFile`n")
        }else{
            $lastCheckSum = (-Split (Get-Content $fileInfo.FullName -Raw))[0]
            if($DebugOn){Write-Host "Last Checksum of ${sourceFilePath}: $lastCheckSum"}

            $startTime = Get-Date
            Write-Host "Creating current checksum of $sourceFilePath [$startTime] ..."
            $currentCheckSum = (certutil -hashfile $sourceFilePath sha256)[1]
            $endTime = Get-Date
            $elapsed = New-TimeSpan -Start $startTime -End $endTime
            Write-Host "Creating current checksum of $sourceFilePath completed. elapsed: $elapsed"

            if($DebugOn){Write-Host "Current Checksum of ${sourceFilePath}: $currentCheckSum"}
            if($lastCheckSum -eq $currentCheckSum){
                Write-Host "Checksums between last and current are matched: $sourceFilePath as $currentCheckSum"
            }else{
                Write-Host "[NG] Checksums between last and current are NOT matched: $sourceFilePath.`n  Current: $currentCheckSum`n  Last: $lastCheckSum"
                $ErrorResult.Append("[NG] Checksums between last and current are NOT matched: $sourceFilePath.`n  Current: $currentCheckSum`n  Last: $lastCheckSum`n")
            }
        }
    }else{
        $checkSumFilePath = $fileInfo.FullName + ".sha256"
        if(-Not (Test-Path $checkSumFilePath)){
            $startTime = Get-Date
            Write-Host "Creating current checksum of $($fileInfo.FullName) [$startTime] ..."
            $currentCheckSum = (certutil -hashfile $fileInfo.FullName sha256)[1]
            $endTime = Get-Date
            $elapsed = New-TimeSpan -Start $startTime -End $endTime
            Write-Host "Creating current checksum of $fileInfo completed. elapsed: $elapsed"

            if($DebugOn){Write-Host "Current Checksum of $($fileInfo.FullName): $currentCheckSum"}
            Write-Output "$currentCheckSum  $($fileInfo.Name)" | Out-File -FilePath $checkSumFilePath
            Write-Host "Check sum of $($fileInfo.FullName) written to ${checkSumFilePath}: $currentCheckSum"
        }
    }
}

if(-Not (Test-Path $targetPath)){
    Write-Host "[NG] Specified file or directory does not exists: $targetPath"
    $ErrorResult.Append("[NG] Specified file or directory does not exists: $targetPath`n")
}else{
    if($DebugOn){Write-Host "Exists: $targetPath"}

    $target = Get-Item $targetPath
    if($target -is [System.IO.DirectoryInfo]){
        SearchDirectory($target)
    }else{
        ProcessFile($target)
    }
}

if($DebugOn){Write-Host "ErrorResult: $ErrorResult"}
if($ErrorResult.Length -eq 0){
    Write-Host "*** Succeeded ***"
}else{
    Write-Host "!!! Some error occured !!!"
    Write-Host $ErrorResult 
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');