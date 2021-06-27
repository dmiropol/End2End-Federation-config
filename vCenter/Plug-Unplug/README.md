# lab-scripts

Repository for scripts related to TPM labs

The script need NOT be run from inside the Lab. It can be run from any host as long as the following NAT rules are configured on the vPodRouter:

* API access for NSX

    iptables -t nat -I PREROUTING -d 192.168.0.2 -p tcp --dport 443 -j DNAT --to-d 192.168.110.201:443

* API access for vCenter

    iptables -t nat -I PREROUTING -d 192.168.0.2 -p tcp --dport 8443 -j DNAT --to-d 192.168.110.22:443

* SSH access to KVM-1 (kvmcomp-01a)

    iptables -t nat -I PREROUTING -d 192.168.0.2 -p tcp --dport 8122 -j DNAT --to-d 192.168.130.151:22

* SSH access to KVM-2 (kvmcomp-02a)

    iptables -t nat -I PREROUTING -d 192.168.0.2 -p tcp --dport 8222 -j DNAT --to-d 192.168.130.152:22

It also uses the following python packages:
  * pyVmomi
  * paramiko

