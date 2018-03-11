Param(
  [string]$mqHost,
  [string]$mqTopic
)

$mqHost = 'darthubuntu'
$mqTopic = 'nodemcu/8824992'
Function Update-LCD{
#Date
$nowdate = Get-date -format g

#CPU
$ProcessorStats = Get-WmiObject win32_processor -Property "LoadPercentage"
$ComputerCpu = $ProcessorStats.LoadPercentage

#Memory
$OperatingSystem = Get-WmiObject win32_OperatingSystem -Property "FreePhysicalMemory","TotalVisibleMemorySize" 
$FreeMemory = $OperatingSystem.FreePhysicalMemory
$TotalMemory = $OperatingSystem.TotalVisibleMemorySize
$MemoryUsed = ($FreeMemory/ $TotalMemory) * 100
#$PercentMemoryUsed =  100 - ("{0:N2}" -f $MemoryUsed)
$PercentMemoryUsed =  ("{0:N0}" -f (100 - $MemoryUsed)).PadLeft(3)


#$mqMessage = '{\"line1\":\"19/02/2018\" ,\"line2\":\"CPU:100% MEM:90%\"}' #Works

$ComputerCPU = ($ComputerCpu.ToString()).PadLeft(3)

$mqMessage = "{\`"line1\`":\`"$nowDate\`" ,\`"line2\`":\`"CPU:$ComputerCpu%MEM:$PercentMemoryUsed%\`"}"
write-verbose $mqMessage
mosquitto_pub -h $mqHost -t $mqTopic -m $mqMessage --will-topic $mqTopic --will-payload "CLS"
}

#Update-LCD

#Main App
Register-EngineEvent PowerShell.Exiting –Action {mosquitto_pub -h $mqHost -t $mqTopic -m "CLS"}

Write-Output "$(get-date -format g) - Clearing screen"
mosquitto_pub -h $mqHost -t $mqTopic -m "CLS"
Write-Output "$(get-date -format g) - Starting output of performance statistics to $mqHost/$mqTopic"
do{
Update-LCD
Start-Sleep -Seconds 1
}
while ($true)