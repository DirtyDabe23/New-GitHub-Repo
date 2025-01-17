#Start Scripts with this:
Clear-Host 
$process = "DocLink Upgrade"
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

    
    #GIT Folder Check Starts
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
        New-Item -itemType Directory -Path C:\ -Name GIT_Scripts -Force -ErrorAction Stop
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

    #Install Utility Download
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Installer Download"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
        Try
        {
            $processPath = "C:\GIT_Scripts\$(Get-Date -format yyyy-MM-dd)_doclink.exe"
            $processArguments = '/s /v"/qn"'
            $url = "https://git-software-deployments.s3.amazonaws.com/DocLink/setup.exe"
            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
            Invoke-WebRequest -Uri $url -OutFile $processPath -erroraction Stop
            Unblock-File -Path $processPath -ErrorAction Stop
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

    #Install Utility Download Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

    
    #Uninstall  Check Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Uninstall"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"
    
    $progs = Get-CimInstance -Class Win32_Product
    If($progs -like "*Altec*")
    {

        #Standard Try Catch Block
            Try
            {
                Get-CimInstance -Class Win32_Product -Filter "Name = '$ProgName'" | Invoke-CimMethod -Name Uninstall -erroraction Stop
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

    #Uninstall Check Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

    #Install Utility Run Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Installer Ran"
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

    #Install Utility Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


    #Profile Removal Starts
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Profile Removal"
    Write-Output "[$($currTime)] | [Endpoint: $currentEndpoint] | [Current User: $loggedInUser] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
        Try
        {
            $loggedInUser = $computerInfo.UserName.split('\')[1]
            $doclinkProfilePath = "C:\Users\$loggedInUser\AppData\Roaming\altec products, inc\doc-link\profiles.dlps"
            If (Test-Path $doclinkProfilePath)
            {
                Remove-Item -Path $doclinkProfilePath -Force -ErrorAction Stop
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

    #Profile Removal Ends
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