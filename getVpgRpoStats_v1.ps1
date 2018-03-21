#CHANGE THESE: Username and password for Zerto Analytics
$zaUsername = "username"
$zaPassword = "password"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11

#Getting Zerto Analytics Token
$body = '{"username": "' + $zaUsername + '","password":"' + $zaPassword + '"}'
$contentType = "application/json"
$xZertoAnalyticsToken = Invoke-RestMethod -Uri "https://analytics.api.zerto.com/v2/auth/token" -Method POST -Body $body -ContentType $contentType

#Build authorization header
$authHeaders = @{"Authorization" = "Bearer " + $xZertoAnalyticsToken.token}

#Set the vpgIdentifier of the VPG you want to pull statistics for
$vpgIdentifier = "xxxxxxxxxxxxxx"

#Get the current time
$CurrentDateTime = Get-Date

#Get current time -5 minutes to pull statistics from last 5 minutes
$ts = New-TimeSpan -Minutes 5
$FiveMinutseAgo = Get-Date($CurrentDateTime-$ts) -Format O

#URL Encode time
$FiveMinutesAgo = [System.Web.HttpUtility]::UrlEncode($FiveMinutesAgo) 

#Get RPO statistics for VPG
$getRpoStatsUrl = "https://analytics.api.zerto.com/v2/reports/stats-rpo?startDate=" + $FiveMinutesAgo + "&vpgIdentifier=" + $vpgIdentifier
$vpgRpoStats = Invoke-RestMethod -Uri $getRpoStatsUrl -Headers $authHeaders 

$avg = $vpgRpoStats.avg
$max = $vpgRpoStats.max
$min = $vpgRpoStats.min

Write-Host @"
<prtg>
<result>
<channel>AvgRPO</channel>
<unit>TimeSeconds</unit>
<value>$avg</value>
<float>1</float>
</result>
<result>
<channel>MaxRPO</channel>
<unit>TimeSeconds</unit>
<value>$max</value>
<float>1</float>
</result>
<result>
<channel>MinRPO</channel>
<unit>TimeSeconds</unit>
<value>$min</value>
<float>1</float>
</result>
</prtg>
"@

