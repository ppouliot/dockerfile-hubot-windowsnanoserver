#Hubot PowerShell Start Script
#Invoke from the PowerShell prompt or start via automated tools 

$HubotPath = "c:\hubot"
$HubotAdapter = "slack"

Write-Host "Starting Hubot Watcher"
While (1)
{
    Write-Host "Starting Hubot"
    Start-Process powershell -ArgumentList "$HubotPath\bin\hubot –-adapter $HubotAdapter" -wait
}
