Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$scriptPath = $MyInvocation.MyCommand.Path
$currentDir = Split-Path -Parent $scriptPath
$parentDir = Split-Path -Parent $currentDir

Write-Host  $args.Count

function SearchDirectory {
    param ($directoryInfo)

    Write-Host "Directory: $($directoryInfo.FullName)"
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

    Write-Host "File: $($fileInfo.Name)"
    if($fileInfo.Name.EndsWith(".sha256")){
        $sourceFilePath = $fileInfo.FullName.Replace(".sha256","")
        if(-Not (Test-Path $sourceFilePath)){
            Write-Host "There is no file corresponding to checksum file: $sourceFile"
            exit 1
        }else{
            $lastCheckSum = (-Split (Get-Content $fileInfo.FullName -Raw))[0]
            Write-Host "Last Checksum of ${sourceFilePath}: $lastCheckSum"
            $currentCheckSum = (certutil -hashfile $sourceFilePath sha256)[1]
            Write-Host "Current Checksum of ${sourceFilePath}: $currentCheckSum"
            if($lastCheckSum -eq $currentCheckSum){
                Write-Host "Checksums between last and current are matched: $sourceFilePath as $currentCheckSum"
            }else{
                Write-Host "[NG]Checksums between last and current are NOT matched: $sourceFilePath.`n  Current: $currentCheckSum`n  Last: $lastCheckSum"
            }
        }
    }else{
        $checkSumFilePath = $fileInfo.FullName + ".sha256"
        if(-Not (Test-Path $checkSumFilePath)){
            $currentCheckSum = (certutil -hashfile $fileInfo.FullName sha256)[1]
            Write-Host "Current Checksum of $($fileInfo.FullName): $currentCheckSum"
            Write-Output $currentCheckSum $fileInfo.Name | Out-File -FilePath $checkSumFilePath
            Write-Host "Check sum of $($fileInfo.FullName) written to ${checkSumFilePath}: $currentCheckSum"
        }
    }
}

foreach($arg in $args){
    if(-Not (Test-Path $arg)){
        Write-Host "Specified file or directory does not exists: $arg"
    }else{
        Write-Host "Exists: $arg"

        $target = Get-Item $arg
        if($target -is [System.IO.DirectoryInfo]){
            SearchDirectory($target)
        }else{
            ProcessFile($target)
        }
    }
}

