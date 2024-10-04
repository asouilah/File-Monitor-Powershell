 Function Calculate-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

 Function Delete-Baseline() {
    $baseExists = Test-Path -Path .\baseline.txt

    if ($baseExists) {
       #Deletes Baseline
       Remove-Item -Path .\baseline.txt
    }
 }

 Write-Host "Select Action" 
 Write-Host ""
 Write-Host "  1) Add New Baseline" -ForegroundColor Yellow
 Write-Host "  2) Monitor Files" -ForegroundColor Yellow
 Write-Host ""
 
 $response = Read-Host -Prompt "Enter Action Choice '1' or '2'" 


 if ($response -eq "1") {
    #Deletes baseline.txt if existing
    Delete-Baseline
    Write-Host "New Baseline has been Created." -ForegroundColor Green
    #Create Hash and store in baseline.txt
    #Collect Files 
    $files = Get-ChildItem -Path .\Files
   
    #Create Hashed File(s), and add baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }

 }

elseif ($response -eq "2") {
    
    $hashKeys = @{}

    #Create Key from baseline.txt/File Hashes
    $filePathsAndHashes = Get-Content -Path .\baseline.txt
    
    foreach ($f in $filePathsAndHashes) {
         $hashKeys.add($f.Split("|")[0],$f.Split("|")[1])
    }

    #Monitor Files with baseline.txt as reference
    while ($true) {
        Write-Host "Monitoring Files..." -ForegroundColor Blue -BackgroundColor White
        Start-Sleep -Seconds 4
        
        $files = Get-ChildItem -Path .\Files

        #Create Hashed File(s), and add baseline.txt
        foreach ($f in $files) {
            $hash = Calculate-Hash $f.FullName
            #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append

            # Notify if a new file has been created
            if ($hashKeys[$hash.Path] -eq $null) {
                # A new file has been created!
                Write-Host "$($hash.Path) has been added." -ForegroundColor Cyan
            }
            else {

                #File not Modified
                if ($hashKeys[$hash.Path] -eq $hash.Hash) {
                   
                }
                else {
                    #File has been Modified
                    Write-Host "$($hash.Path) has been modified." -ForegroundColor Red
                }
            }
        }

        foreach ($key in $hashKeys.Keys) {
            $baseExists = Test-Path -Path $key
            if (-Not $baseExists) {
                #Baseline Modified/Removed
                Write-Host "$($key) has been removed." -ForegroundColor Magenta
            }
        }
    }
}