#Hubot PowerShell Start Script
#Invoke from the PowerShell prompt or start via automated tools 

$HubotPath = "drive:\path\to\hubot"
$HubotAdapter = "Hubot adapter"

setx "HUBOT_SLACK_TOKEN" $env:HUBOT_SLACK_TOKEN
Write-Host "Starting Hubot Watcher"
While (1)
{
    Write-Host "Starting Hubot"
    Start-Process powershell -ArgumentList "$HubotPath\bin\hubot –adapter $HubotAdapter" -wait
}
