if (!(test-path ("C:\temp\"))){
    mkdir "C:\temp\"
}
$log = "C:\temp\PingLog.txt"
add-content $log ("------------`n`n`nRoute connectivity tester started at " + (Get-Date -Format "MM/dd HH:mm:ss"))

$routeTargets = [System.Collections.ArrayList]@("8.8.8.8", "1.1.1.1")
$additionalIPs = [System.Collections.ArrayList]@("192.168.0.151")

$routeList = [System.Collections.ArrayList]@()
foreach ($routeTarget in $routeTargets){
    $routeList += (test-netconnection -traceroute $routeTarget).traceroute
}

$pingTargets = [System.Collections.ArrayList]@()
foreach ($IP in $routeList){
    if ($IP -eq '0.0.0.0'){
        #do not add 0.0.0.0 non-responses to target list
    }
    elseif (!($pingTargets -contains $IP)){
        $pingTargets += $IP
    }
    else{
        #skip adding duplicates
    }
}
$pingTargets += $additionalIPs

$pingTimeout = 500 #in ms
$downCountThreshold = 2
$loopBuffer = 1

add-content $log ("Ping targets: " + $pingTargets)
add-content $log ("Timeout: " + $pingTimeout + "ms")
add-content $log ("loopBuffer = " + $loopBuffer + " second(s)")
add-content $log ("`n`n`n")

Function ResultSpacing($currentIP){
    $ipLength = ($currentIP | measure-object -character).characters
    $addSpaces = (16 - $ipLength)
    while ($addSpaces -gt 0){
        $currentIP += " "
        $addSpaces --
    }
    return ($currentIP + "`t")
}

while($true){
    $downCount = 0
    $logBatch = ""
    foreach($pingTarget in $pingTargets){
        $pingStatus = (New-Object System.Net.NetworkInformation.Ping).Send($pingTarget, $pingTimeout).Status
        if($pingStatus -eq 'Success'){
            $logBatch += ((ResultSpacing $pingTarget) + "is Up at " + (Get-Date -Format "MM/dd HH:mm:ss") + "`n")
        }
        elseif($pingStatus -eq 'TimedOut'){
            $logBatch += ((ResultSpacing $pingTarget) + "is Down at " + (Get-Date -Format "MM/dd HH:mm:ss") + "`n")
            $downCount++
        } 
        else{
            $logBatch += (ResultSpacing($pingTarget) + "Error at " + (Get-Date -Format "MM/dd HH:mm:ss") + "`n")
            $downCount++
        }
    }
    if ($downCount -gt $downCountThreshold){
        $logBatch +=  "Down threshold met: yes"
    }
    else{
        $logBatch +=  "Down threshold met: no"
    }
    add-content $log ($logBatch + "`n`n") 
    start-sleep $loopBuffer
}

