Write-Host  $args.Count

function SearchDirectory {
    param ($directoryInfo)

    Write-Host "Directory: $($directoryInfo.FullName)"
}

function ProcessFile{
    param($fileInfo)

    Write-Host "File: $($fileInfo.Name)"
}

foreach($arg in $args){
    if(-Not (Test-Path $arg)){
        Write-Host "ë∂ç›ÇµÇ‹ÇπÇÒ: $arg"
    }else{
        Write-Host "ë∂ç›ÇµÇ‹Ç∑: $arg"

        $target = Get-Item $arg
        if($target -is [System.IO.DirectoryInfo]){
            SearchDirectory($target)
        }else{
            ProcessFile($target)
        }
    }
}

