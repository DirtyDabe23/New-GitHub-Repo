#Start Scripts with this:
Clear-Host 
$process = "Citrix Upgrade"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process

#This WMI Query gets a ton of rich information about the endpoint
$computerInfo = Get-WMIObject -class Win32_ComputerSystem | select-object -Property *
$loggedInUser = $computerInfo.UserName.split('\')[1]
$currentEndpoint = $computerInfo.Name


#Error Logging
$errorLogFull = @()


#Log Timing For the Full Process Start
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | Starting"

    
    #Folder Check Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "GIT Folder Check"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
    Try
    {
    #$Path is the containing folder for the process.
    $Path = "C:\GIT_Scripts"
    if (!(Test-Path $Path))
    {
        New-Item -itemType Directory -Path C:\ -Name GIT_Scripts -Force -ErrorAction Stop | Out-Null
    }
    else
    {
        Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Folder Exists"
    }

    }
    Catch
    {
        $errorLog += [PSCustomObject]@{
            processFailed                   = $procProcess
            timeToFail                      = $procStartTime
            reasonFailed                    = $error[0] #gets the most recent error
            failedTargetStandardName        = $computerInfo.Name
            failedTargetDNSName             = $computerInfo.DNSHostName
            failedTargetUser                = $computerInfo.Username
            failedTargetWorkGroup           = $computerInfo.Workgroup
            failedTargetDomain              = $computerInfo.Domain
            failedTargetMemory              = $computerInfo.TotalPhysicalMemory
            failedTargetChassis             = $computerInfo.ChassisSKUNumber
            failedTargetManufacturer        = $computerInfo.Manufacturer
            failedTargetModel               = $computerInfo.Model

        }
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Failed. Details Below:"
        Write-Output $errorLog
        $errorLogFull += $errorLog | select-object -last 1
        #If we are unable to make the folder, exit here.
        exit 1
    }

    #Folder Check Function Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

    #Uninstall Utility Download
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Uninstall Utility Download"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"
    $processPath = "C:\GIT_Scripts\ReceiveCleanupUtility.exe"
    $processArguments = '/uninstall /silent'
    if (!(Test-Path -Path $processPath))
    {
    #Standard Try Catch Block
        Try
        {
            $url = "https://git-software-deployments.s3.amazonaws.com/Citrix/ReceiverCleanupUtility.exe"
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
            Invoke-WebRequest -Uri $url -OutFile $processPath -erroraction Stop
        }
        Catch
        {
            $errorLog += [PSCustomObject]@{
                processFailed                   = $procProcess
                timeToFail                      = $procStartTime
                reasonFailed                    = $error[0] #gets the most recent error
                failedTargetStandardName        = $computerInfo.Name
                failedTargetDNSName             = $computerInfo.DNSHostName
                failedTargetUser                = $computerInfo.Username
                failedTargetWorkGroup           = $computerInfo.Workgroup
                failedTargetDomain              = $computerInfo.Domain
                failedTargetMemory              = $computerInfo.TotalPhysicalMemory
                failedTargetChassis             = $computerInfo.ChassisSKUNumber
                failedTargetManufacturer        = $computerInfo.Manufacturer
                failedTargetModel               = $computerInfo.Model

            }
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Failed. Details Below:"
            Write-Output $errorLog
            $errorLogFull += $errorLog | select-object -last 1
            
        }
    }
    Else
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] [$processPath] Already Exists, Proceeding"  
    }

    #Uninstall Utility Download Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

    #Process Check Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Running Process Check"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
        Try
        {
            $procName = 'Receiver'
            $procs = Get-Process | Select-Object -Property *
            If ($procs.name -notcontains $procName)
            {
                Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Process: $procName Not Detected. Proceeding."
            }
            Else
            {
                $procRunning = $true
                $currTime = Get-Date -format "HH:mm"
                Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Process:$procName Running. Waiting for User to Exit"
                Start-Sleep -Seconds 10
    
                while ($procRunning -eq $true)
                {
                    Try{
                        $currTime = Get-Date -format "HH:mm"
                        Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Process:$procName Waiting for User to Exit"
                        Get-Process -name $procName -ErrorAction Stop | Stop-Process -Force
                        Start-Sleep -seconds 10
                    } 
                    Catch 
                    {
                        $currTime = Get-Date -format "HH:mm"
                        Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Process:$procName Closed. Considered Complete"
                        $procRunning = $false
                    }
    
                }  
            }

        }
        Catch
        {
            $errorLog += [PSCustomObject]@{
                processFailed                   = $procProcess
                timeToFail                      = Get-Date
                reasonFailed                    = $error[0] #gets the most recent error
                failedTargetStandardName        = $computerinfo.Name
                failedTargetDNSName             = $computerinfo.DNSHostName
                failedTargetUser                = $computerInfo.Username
                failedTargetWorkGroup           = $computerInfo.Workgroup
                failedTargetDomain              = $computerInfo.Domain
                failedTargetMemory              = $computerInfo.TotalphysicalMemory
                failedTargetChassis             = $computerInfo.ChassisSKUNumber
                failedTargetManufacturer        = $computerInfo.Manufacturer
                failedTargetModel               = $computerInfo.Model

            }
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Failed. Details Below:"
            Write-Output $errorLog
            $errorLogFull = $errorLog | select-object -last 1
            
        }

    #Function Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

    #Uninstall Utility Run Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Uninstall Utility Ran"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
        Try
        {
            Start-Process -FilePath $processPath -ArgumentList $processArguments -Wait -NoNewWindow -ErrorAction Stop
        }
        Catch
        {
            $errorLog += [PSCustomObject]@{
                processFailed                   = $procProcess
                timeToFail                      = $procStartTime
                reasonFailed                    = $error[0] #gets the most recent error
                failedTargetStandardName        = $computerInfo.Name
                failedTargetDNSName             = $computerInfo.DNSHostName
                failedTargetUser                = $computerInfo.Username
                failedTargetWorkGroup           = $computerInfo.Workgroup
                failedTargetDomain              = $computerInfo.Domain
                failedTargetMemory              = $computerInfo.TotalPhysicalMemory
                failedTargetChassis             = $computerInfo.ChassisSKUNumber
                failedTargetManufacturer        = $computerInfo.Manufacturer
                failedTargetModel               = $computerInfo.Model

            }
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Failed. Details Below:"
            Write-Output $errorLog
            $errorLogFull += $errorLog | select-object -last 1
            
        }

    #Uninstall Utility Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


    #Install Utility Download
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Install Download"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"
    $processPath = "C:\GIT_Scripts\CitrixWorkspaceApp.exe"
    $processArguments = '/silent /noreboot /autoUpdateCheck=Auto'
    If (!(Test-Path -Path $processPath))
    {
    #Standard Try Catch Block
        Try
        {
            $url = "https://git-software-deployments.s3.amazonaws.com/Citrix/CitrixWorkspaceApp.exe"
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
            Invoke-WebRequest -Uri $url -OutFile $processPath -erroraction Stop
        }
        Catch
        {
            $errorLog += [PSCustomObject]@{
                processFailed                   = $procProcess
                timeToFail                      = $procStartTime
                reasonFailed                    = $error[0] #gets the most recent error
                failedTargetStandardName        = $computerInfo.Name
                failedTargetDNSName             = $computerInfo.DNSHostName
                failedTargetUser                = $computerInfo.Username
                failedTargetWorkGroup           = $computerInfo.Workgroup
                failedTargetDomain              = $computerInfo.Domain
                failedTargetMemory              = $computerInfo.TotalPhysicalMemory
                failedTargetChassis             = $computerInfo.ChassisSKUNumber
                failedTargetManufacturer        = $computerInfo.Manufacturer
                failedTargetModel               = $computerInfo.Model

            }
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Failed. Details Below:"
            Write-Output $errorLog
            $errorLogFull += $errorLog | select-object -last 1
            
        }
    }
    else 
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] [$processPath] Already Exists, Proceeding"  
    }

    #Install Download Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

    #Install Run Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Installer"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
        Try
        {
            Start-Process -FilePath $processPath -ArgumentList $processArguments -ErrorAction Stop
            $procName = "CWAInstaller"
            $procRunning = $true
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Install Process Generating"
            Start-Sleep -Seconds 60

            while ($procRunning -eq $true)
            {
                Try{
                    $currTime = Get-Date -format "HH:mm"
                    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Waiting for Completion"
                    Get-Process -name $procName -ErrorAction Stop | Out-Null
                    Start-Sleep -seconds 10
                } 
                Catch 
                {
                    $currTime = Get-Date -format "HH:mm"
                    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess]  Install Process Not Detected, Considered Complete"
                    $procRunning = $false
                }

            }

        }
        Catch
        {
            $errorLog += [PSCustomObject]@{
                processFailed                   = $procProcess
                timeToFail                      = $procStartTime
                reasonFailed                    = $error[0] #gets the most recent error
                failedTargetStandardName        = $computerInfo.Name
                failedTargetDNSName             = $computerInfo.DNSHostName
                failedTargetUser                = $computerInfo.Username
                failedTargetWorkGroup           = $computerInfo.Workgroup
                failedTargetDomain              = $computerInfo.Domain
                failedTargetMemory              = $computerInfo.TotalPhysicalMemory
                failedTargetChassis             = $computerInfo.ChassisSKUNumber
                failedTargetManufacturer        = $computerInfo.Manufacturer
                failedTargetModel               = $computerInfo.Model

            }
            $currTime = Get-Date -format "HH:mm"
            Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Failed. Details Below:"
            Write-Output $errorLog
            $errorLogFull += $errorLog | select-object -last 1
            
        }

    #Install Run Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

    
    
#For Full Script End:
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | Time taken for [$process] Completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
if ($errorLogFull -eq '')
{
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | Completed with no errors"
}
Else
{
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | Errors: `n`n`n"
    Write-Output $errorLogFull
}