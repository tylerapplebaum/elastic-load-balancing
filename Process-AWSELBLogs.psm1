# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
Function Process-AWSELBLogs {
param(
[CmdletBinding()]
    [Parameter(HelpMessage="Specify the path to the directory containing ELB log files in .txt format")]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]$LogDir
)
$script:LogArr = New-Object System.Collections.ArrayList
$LogFilesRaw = Get-ChildItem -Path $LogDir -Filter *.txt
    ForEach ($LogFileRaw in $LogFilesRaw) {
        $LogContent = Get-Content $LogFileRaw.Fullname | Where-Object Length -gt 0
        ForEach ($LogEntry in $LogContent){
            $LogData = $LogEntry -split ' +(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)'
            $LogProperties = [Ordered]@{ #Null LogData is marked with a '-'
                'type' = $LogData[0]
                'timestamp' = $LogData[1]
                'elb' = $LogData[2]
                'client:port' = $LogData[3]
                'target:port' = $LogData[4]
                'request_processing_time' = $LogData[5]
                'target_processing_time' = $LogData[6]
                'response_processing_time' = $LogData[7]
                'elb_status_code' = $LogData[8]
                'target_status_code' = $LogData[9]
                'received_bytes' = $LogData[10]
                'sent_bytes' = $LogData[11]
                '"request"' = $LogData[12]
                '"user_agent"' = $LogData[13]
                'ssl_cipher' = $LogData[14]
                'ssl_protocol' = $LogData[15]
                'target_group_arn' = $LogData[16]
                '"trace_id"' = $LogData[17]
                '"domain_name"' = $LogData[18]
                '"chosen_cert_arn"' = $LogData[19]
                'matched_rule_priority' = $LogData[20]
                'request_creation_time' = $LogData[21]
                '"actions_executed"' = $LogData[22]
                '"redirect_url"' = $LogData[23]
                '"error_reason"' = $LogData[24]
                '"target:port_list"' = $LogData[25]
                '"target_status_code_list"' = $LogData[26]
                'sortabletimestamp' = [datetime]$LogData[1] #Artifical property added for sorting
            }
            $LogObject = New-Object PSObject -Property $LogProperties
            $LogArr.Add($LogObject) | Out-Null
        }
    }
    $LogArr | Sort-Object sortabletimestamp | Export-CSV -Path $LogDir\ELB-Logs-$(Get-Date -Format yyyy-MM-dd).csv -NoTypeInformation 
    Return [void]$LogArr
} #End Process-AWSELBLogs