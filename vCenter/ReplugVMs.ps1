Connect-VIServer -Server vcsa-01a.corp.local -Protocol https -User administrator@vsphere.local -Password VMware1!



$OldNetwork = "LabNet"
$NewNetwork = "web-seg"
$VMName = "Web01"
Get-VM -Name $VMName |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetwork } |Set-NetworkAdapter -Portgroup $NewNetwork -Confirm:$false


$OldNetwork = "LabNet"
$NewNetwork = "web-seg"
$VMName = "Web02"
Get-VM -Name $VMName |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetwork } |Set-NetworkAdapter -Portgroup $NewNetwork -Confirm:$false



$OldNetwork = "LabNet"
$NewNetwork = "db-seg"
$VMName = "DB01"
Get-VM -Name $VMName |Get-NetworkAdapter |Where {$_.NetworkName -eq $OldNetwork } |Set-NetworkAdapter -Portgroup $NewNetwork -Confirm:$false

