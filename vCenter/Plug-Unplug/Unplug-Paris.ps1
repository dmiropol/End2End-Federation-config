Connect-VIServer -Server 192.168.110.151 -Protocol https -User root -Password VMware1!
$VM = "vCenter-Paris"
get-vm $VM | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$false -StartConnected:$true -Confirm:$false | Out-Null

Connect-VIServer -Server 192.168.120.151 -Protocol https -User root -Password VMware1!
$VM = "SRM-Paris"
get-vm $VM | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$false -StartConnected:$true -Confirm:$false | Out-Null

Connect-VIServer -Server 192.168.120.152 -Protocol https -User root -Password VMware1!
$VM = "vSphere_Replication_Paris"
get-vm $VM | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$false -StartConnected:$true -Confirm:$false | Out-Null
