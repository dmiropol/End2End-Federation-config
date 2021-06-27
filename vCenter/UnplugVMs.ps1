Connect-VIServer -Server vcsa-01a.corp.local -Protocol https -User administrator@vsphere.local -Password VMware1!



$OldNetwork = "web-seg"
$NewNetwork = "LabNet"

$VMName = "Web01"
Get-VM -Name $VMName |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetwork } |Set-NetworkAdapter -Portgroup $NewNetwork -Confirm:$false


$OldNetwork = "web-seg"
$NewNetwork = "LabNet"
$VMName = "Web02"
Get-VM -Name $VMName |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetwork } |Set-NetworkAdapter -Portgroup $NewNetwork -Confirm:$false


$OldNetwork = "db-seg"
$NewNetwork = "LabNet"
$VMName = "DB01"
Get-VM -Name $VMName |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetwork } |Set-NetworkAdapter -Portgroup $NewNetwork -Confirm:$false

