$ComputerNames=("VM1","DC2")
#Install IIS & NLB per configuration file
$js = @()
foreach($ComputerName in $ComputerNames) {
    $js += Start-Job -Command {
        Install-WindowsFeature "Web-Default-Doc","Web-Dir-Browsing","Web-Http-Errors","Web-Static-Content","Web-Http-Logging","Web-Stat-Compression","Web-Filtering","Web-Mgmt-Console","NLB","RSAT-NLB" -ComputerName $using:ComputerName -Restart
    }
}
Receive-Job -Job $js -Wait
#Install RSAT NLB Configuration
Install-WindowsFeature RSAT-NLB
$DNSZone = "adatum.com"
$primaryHost = "VM1.$($DNSZone)"
$secondaryHost = "DC2.$($DNSZone)"
$ClusterBaseName = "www"
$ClusterAName = "$($ClusterBaseName).$($DNSZone)"
$interface = "Ethernet"
$ClusterIP = "10.0.10.50"
$ClusterSN = "255.255.255.0"
$ClusterPorts = (80,443)
$ClusterFrom = "255.255.255.255"
#create a new cluster

$cluster = (New-NLBCluster -HostName $primaryHost -InterfaceName $interface -ClusterName $ClusterAName -ClusterPrimaryIP $ClusterIP -SubnetMask $ClusterSN -OperationMode "Multicast")
#Add a new node to the cluster
$cluster | Add-NLBClusterNode -NewNodeName $secondaryHost -NewNodeInterface $interface
#Add port rules to the cluster
$cluster | Get-NLBClusterPortRule | Remove-NLBClusterPortRule -Force
foreach ($Port in $ClusterPorts) {
    $cluster | Add-NLBClusterPortRule -IP $ClusterFrom -Protocol TCP -StartPort $Port -EndPort $Port -Mode "Multiple" -Affinity "Single" -Timeout 0
}
#Create an identification file
foreach($ComputerName in $ComputerNames) {
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { $Env:ComputerName | Out-File C:\INETPUB\WWWROOT\default.htm -Encoding ASCII }
}
#Create DNS Records
Add-DnsServerResourceRecordA -Name $ClusterBaseName -IPv4Address $ClusterIP -ZoneName $DNSZone
Add-DnsServerResourceRecordCName -Name "www" -HostNameAlias $ClusterBaseName -ZoneName $DNSZone
#both up
(Invoke-WebRequest http://www.adatum.com).Content
$cluster | Get-NlbClusterNode $primaryHost | Stop-NlbClusterNode
#should get from Secondary
(Invoke-WebRequest http://www.adatum.com).Content
$cluster | Get-NlbClusterNode $primaryHost | Start-NlbClusterNode
$cluster | Get-NlbClusterNode $secondaryHost | Stop-NlbClusterNode
#Should get from Primary
(Invoke-WebRequest http://www.adatum.com).Content
$cluster | Get-NlbClusterNode $secondaryHost | Start-NlbClusterNode
#both up
(Invoke-WebRequest http://www.adatum.com).Content