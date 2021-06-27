# Copyright 2017-2021 VMware, Inc.  All rights reserved
#
# The BSD-2 license (the "License") set forth below applies to all
# parts of the NSX-T SDK Sample Code project.  You may not use this
# file except in compliance with the License.
# BSD-2 License
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#     Redistributions of source code must retain the above
#     copyright notice, this list of conditions and the
#     following disclaimer.
#     Redistributions in binary form must reproduce the above
#     copyright notice, this list of conditions and the
#     following disclaimer in the documentation and/or other
#     materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
# USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
      version = "3.2.1"
    }
  }
}

provider "nsxt" {
  host                 = "gm-paris"
  username             = "admin"
  password             = "VMware1!VMware1!"
  global_manager       = "true"
  allow_unverified_ssl = true
}

provider "nsxt" {
  alias                = "paris"
  host                 = "lm-paris"
  username             = "admin"
  password             = "VMware1!VMware1!"
  allow_unverified_ssl = true
}

provider "nsxt" {
  alias                = "london"
  host                 = "lm-london"
  username             = "admin"
  password             = "VMware1!VMware1!"
  allow_unverified_ssl = true
} 

provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "VMware1!"
  vsphere_server = "vcsa-01a"
  allow_unverified_ssl = true
}

provider "vsphere" {
  alias          = "london"
  user           = "administrator@vsphere.local"
  password       = "VMware1!"
  vsphere_server = "vcsa-01b"
  allow_unverified_ssl = true
}

##############################
# Infra configuration section
##############################

# Sites definitions
data "nsxt_policy_site" "paris" {
  display_name = "LM_Paris"
}

data "nsxt_policy_site" "london" {
  display_name = "LM_London"
}

# Transport zones definitions
data "nsxt_policy_transport_zone" "paris_overlay_tz" {
  display_name = "nsx-overlay-transportzone"
  site_path    = data.nsxt_policy_site.paris.path
}

data "nsxt_policy_transport_zone" "london_overlay_tz" {
  display_name = "nsx-overlay-transportzone"
  site_path    = data.nsxt_policy_site.london.path
}

data "nsxt_policy_transport_zone" "paris-uplinks-vlan-tz" {
  display_name = "nsx-uplinks-vlan-transportzone"
  site_path    = data.nsxt_policy_site.paris.path
}

data "nsxt_policy_transport_zone" "london-uplinks-vlan-tz" {
  display_name = "nsx-uplinks-vlan-transportzone"
  site_path    = data.nsxt_policy_site.london.path
}

# Edge nodes and cluster definitions
data "nsxt_policy_edge_node" "edgenode-01a" {
    display_name        = "edgenode-01a"
    edge_cluster_path   = data.nsxt_policy_edge_cluster.paris.path
}

data "nsxt_policy_edge_node" "edgenode-02a" {
    display_name        = "edgenode-02a"
    edge_cluster_path   = data.nsxt_policy_edge_cluster.paris.path
}

data "nsxt_policy_edge_node" "edgenode-01b" {
    display_name        = "edgenode-01b"
    edge_cluster_path   = data.nsxt_policy_edge_cluster.london.path
}

data "nsxt_policy_edge_node" "edgenode-02b" {
    display_name        = "edgenode-02b"
    edge_cluster_path   = data.nsxt_policy_edge_cluster.london.path
}

data "nsxt_policy_edge_cluster" "paris" {
  display_name = "EdgeCluster"
  site_path    = data.nsxt_policy_site.paris.path
}

data "nsxt_policy_edge_cluster" "london" {
  display_name = "EdgeCluster"
  site_path    = data.nsxt_policy_site.london.path
}

# VLAN segment definitions for T0 interface uplinks
resource "nsxt_policy_vlan_segment" "Paris_left-vlan-seg" {
  display_name        = "Paris_left-vlan-seg"
  nsx_id              = "Paris_left-vlan-seg"
  transport_zone_path = data.nsxt_policy_transport_zone.paris-uplinks-vlan-tz.path
  vlan_ids            = ["240"]
}

resource "nsxt_policy_vlan_segment" "Paris_right-vlan-seg" {
  display_name        = "Paris_right-vlan-seg"
  description         = "Paris_right-vlan-seg"
  transport_zone_path = data.nsxt_policy_transport_zone.paris-uplinks-vlan-tz.path
  vlan_ids            = ["250"]
}

resource "nsxt_policy_vlan_segment" "London_left-vlan-seg" {
  display_name        = "London_left-vlan-seg"
  nsx_id              = "London_left-vlan-seg"
  transport_zone_path = data.nsxt_policy_transport_zone.london-uplinks-vlan-tz.path
  vlan_ids            = ["243"]
}

resource "nsxt_policy_vlan_segment" "London_right-vlan-seg" {
  display_name        = "London_right-vlan-seg"
  description         = "London_right-vlan-seg"
  transport_zone_path = data.nsxt_policy_transport_zone.london-uplinks-vlan-tz.path
  vlan_ids            = ["253"]
}


##############################
# Routing configuration section
##############################

# T0 definitions
resource "nsxt_policy_tier0_gateway" "global_t0" {
  display_name              = "T0-ParisLondon"
  nsx_id                    = "T0-ParisLondon"
  description               = "Global Tier-0 for Paris and London locations"
  failover_mode             = "PREEMPTIVE"
  default_rule_logging      = false
  enable_firewall           = false
  locale_service {
    edge_cluster_path = data.nsxt_policy_edge_cluster.paris.path
  }
  locale_service {
    edge_cluster_path = data.nsxt_policy_edge_cluster.london.path
  }
  intersite_config {
    primary_site_path = data.nsxt_policy_site.paris.path
  }
}

resource "nsxt_policy_gateway_redistribution_config" "t0_redistribute_paris" {
  gateway_path = nsxt_policy_tier0_gateway.global_t0.path
  site_path    = data.nsxt_policy_site.paris.path
  bgp_enabled = true
  rule {
    name  = "TIER1_CONNECTED"
    types = ["TIER1_CONNECTED"]
  }
}

resource "nsxt_policy_gateway_redistribution_config" "t0_redistribute_london" {
  gateway_path = nsxt_policy_tier0_gateway.global_t0.path
  site_path    = data.nsxt_policy_site.london.path
  bgp_enabled = true
  rule {
    name  = "TIER1_CONNECTED"
    types = ["TIER1_CONNECTED"]
  }
}

#  T0 Interfaces  
resource "nsxt_policy_tier0_gateway_interface" "Paris_left-intf" {
  display_name           = "Paris_left-intf"
  nsx_id                 = "Paris_left-intf"
  type                   = "EXTERNAL"
  site_path              = data.nsxt_policy_site.paris.path
  gateway_path           = nsxt_policy_tier0_gateway.global_t0.path
  segment_path           = nsxt_policy_vlan_segment.Paris_left-vlan-seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edgenode-01a.path
  subnets                = ["192.168.240.11/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "Paris_right-intf" {
  display_name           = "Paris_right-intf"
  description            = "Paris_right-intf"
  type                   = "EXTERNAL"
  site_path              = data.nsxt_policy_site.paris.path
  gateway_path           = nsxt_policy_tier0_gateway.global_t0.path
  segment_path           = nsxt_policy_vlan_segment.Paris_right-vlan-seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edgenode-02a.path
  subnets                = ["192.168.250.11/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "London_left-intf" {
  display_name           = "London_left-intf"
  nsx_id                 = "London_left-intf"
  type                   = "EXTERNAL"
  site_path              = data.nsxt_policy_site.london.path
  gateway_path           = nsxt_policy_tier0_gateway.global_t0.path
  segment_path           = nsxt_policy_vlan_segment.London_left-vlan-seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edgenode-01b.path
  subnets                = ["192.168.243.11/24"]
}

resource "nsxt_policy_tier0_gateway_interface" "London_right-intf" {
  display_name           = "London_right-intf"
  description            = "London_right-intf"
  type                   = "EXTERNAL"
  site_path              = data.nsxt_policy_site.london.path
  gateway_path           = nsxt_policy_tier0_gateway.global_t0.path
  segment_path           = nsxt_policy_vlan_segment.London_right-vlan-seg.path
  edge_node_path         = data.nsxt_policy_edge_node.edgenode-02b.path
  subnets                = ["192.168.253.11/24"]
}


# BGP configuration
resource "nsxt_policy_bgp_config" "Paris_global_bgp_t0" {
  site_path             = data.nsxt_policy_site.paris.path
  gateway_path          = nsxt_policy_tier0_gateway.global_t0.path
  enabled               = true
  inter_sr_ibgp         = true
  local_as_num          = 100
  graceful_restart_mode = "HELPER_ONLY"
}

resource "nsxt_policy_bgp_config" "London_global_bgp_t0" {
  site_path             = data.nsxt_policy_site.london.path
  gateway_path          = nsxt_policy_tier0_gateway.global_t0.path
  enabled               = true
  inter_sr_ibgp         = true
  local_as_num          = 100
  graceful_restart_mode = "HELPER_ONLY"
}

resource "nsxt_policy_bgp_neighbor" "Paris_bgp_left" {
  display_name          = "Paris_bgp_left"
  nsx_id                = "Paris_bgp_left"
  bgp_path              = nsxt_policy_bgp_config.Paris_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 4
  keep_alive_time       = 1
  neighbor_address      = "192.168.240.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.Paris_left-intf.ip_addresses[0]]
  bfd_config {
    enabled  = true
    interval = 500
    multiple = 3
  }
}

resource "nsxt_policy_bgp_neighbor" "Paris_bgp_right" {
  display_name          = "Paris_bgp_right"
  nsx_id                = "Paris_bgp_right"
  bgp_path              = nsxt_policy_bgp_config.Paris_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 4
  keep_alive_time       = 1
  neighbor_address      = "192.168.250.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.Paris_right-intf.ip_addresses[0]]
  bfd_config {
    enabled  = true
    interval = 500
    multiple = 3
  }
}

resource "nsxt_policy_bgp_neighbor" "London_bgp_left" {
  display_name          = "London_bgp_left"
  nsx_id                = "London_bgp_left"
  bgp_path              = nsxt_policy_bgp_config.London_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 4
  keep_alive_time       = 1
  neighbor_address      = "192.168.243.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.London_left-intf.ip_addresses[0]]
  bfd_config {
    enabled  = true
    interval = 500
    multiple = 3
  }
}

resource "nsxt_policy_bgp_neighbor" "London_bgp_right" {
  display_name          = "London_bgp_right"
  nsx_id                = "London_bgp_right"
  bgp_path              = nsxt_policy_bgp_config.London_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 4
  keep_alive_time       = 1
  neighbor_address      = "192.168.253.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.London_right-intf.ip_addresses[0]]
  bfd_config {
    enabled  = true
    interval = 500
    multiple = 3
  }
}


# Global T1 definitions
resource "nsxt_policy_tier1_gateway" "paris_london_t1" {
  display_name = "T1DR-ParisLondon"
  nsx_id       = "T1DR-ParisLondon"
  tier0_path   = nsxt_policy_tier0_gateway.global_t0.path
  route_advertisement_types = ["TIER1_CONNECTED"]
  /* only DR is being used
  locale_service {
    edge_cluster_path = data.nsxt_policy_edge_cluster.paris.path
  }
  locale_service {
    edge_cluster_path = data.nsxt_policy_edge_cluster.london.path
  }
  intersite_config {
    primary_site_path = data.nsxt_policy_site.paris.path
  }
  */
}


##############################
# Security configuration section
##############################

#  Segments definitions 
resource "nsxt_policy_segment" "global_web_segment" {
  display_name      = "web-seg"
  nsx_id            = "web-seg"
  connectivity_path = nsxt_policy_tier1_gateway.paris_london_t1.path
  subnet {
    cidr = "172.16.10.1/24"
  }
  advanced_config {
    connectivity = "ON"
  }
}

resource "nsxt_policy_segment" "global_db_segment" {
  display_name      = "db-seg"
  nsx_id            = "db-seg"
  connectivity_path = nsxt_policy_tier1_gateway.paris_london_t1.path
  subnet {
    cidr = "172.16.20.1/24"
  }
  advanced_config {
    connectivity = "ON"
  }
}

# Security groups definitions
resource "nsxt_policy_group" "web_vm_group" {
  display_name = "Web-VM-Group"
  nsx_id       = "Web-VM-Group"
  criteria {
    condition {
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      key         = "Tag"
      value       = "Web"
    }
  }
  conjunction {
    operator = "OR"
  }
  criteria {
    condition {
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      key         = "Name"
      value       = "Web"
    }
  }
}

resource "nsxt_policy_group" "db_vm_group" {
  display_name = "DB-VM-Group"
  nsx_id       = "DB-VM-Group"
  criteria {
    condition {
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      key         = "Tag"
      value       = "DB"
    }
  }
  conjunction {
    operator = "OR"
  }
  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = "DB"
    }
  }
}

resource "nsxt_policy_group" "mgmt-ip" {
  display_name = "Mgmt-IP"
  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10"]
    }
  }
}

# services definitions
data "nsxt_policy_service" "service_icmp" {
  display_name = "ICMP ALL"
}

data "nsxt_policy_service" "service_ssh" {
  display_name = "SSH"
}

data "nsxt_policy_service" "service_https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "service_mysql" {
  display_name = "MySQL"
}


# DFW policy configuration
resource "nsxt_policy_security_policy" "management-access" {
  display_name = "Management Access"
  category     = "Infrastructure"
  rule {
    display_name       = "Management SSH + ICMP"
    source_groups      = [nsxt_policy_group.mgmt-ip.path]
    destination_groups = [nsxt_policy_group.db_vm_group.path, nsxt_policy_group.web_vm_group.path]
    services           = [data.nsxt_policy_service.service_ssh.path, data.nsxt_policy_service.service_icmp.path]
    scope              = [nsxt_policy_group.db_vm_group.path, nsxt_policy_group.web_vm_group.path]
    action             = "ALLOW"
  }
}

resource "nsxt_policy_security_policy" "two_tier_app" {
  display_name = "2Tier-app"
  nsx_id       = "2Tier-app"
  category     = "Application"
  stateful     = true
  sequence_number = "10"
  rule {
    display_name       = "Any to Web"
    destination_groups = [nsxt_policy_group.web_vm_group.path]
    scope              = [nsxt_policy_group.web_vm_group.path]
    services           = [data.nsxt_policy_service.service_icmp.path,data.nsxt_policy_service.service_https.path]
    action             = "ALLOW"
  }
  rule {
    display_name       = "Web to DB"
    source_groups      = [nsxt_policy_group.web_vm_group.path]
    destination_groups = [nsxt_policy_group.db_vm_group.path]
    scope              = [nsxt_policy_group.web_vm_group.path,nsxt_policy_group.db_vm_group.path]
    services           = [data.nsxt_policy_service.service_mysql.path]
    action             = "ALLOW"
  }
  rule {
    display_name       = "Deny All"
    destination_groups = [nsxt_policy_group.web_vm_group.path,nsxt_policy_group.db_vm_group.path]
    scope              = [nsxt_policy_group.web_vm_group.path,nsxt_policy_group.db_vm_group.path]
    action             = "REJECT"
  }
}


############################################
# working with vSphere VM objects for NSXT tagging
############################################

data "vsphere_datacenter" "DC-Paris" {
  name = "DC-Paris"
}

data "vsphere_datacenter" "DC-London" {
  name = "DC-London"
  provider = vsphere.london
}

# Paris VMs
data "vsphere_virtual_machine" "Web01_Paris" {
  name          = "Web01"
  datacenter_id = "${data.vsphere_datacenter.DC-Paris.id}"
}
resource "nsxt_policy_vm_tags" "web01_vm_tags_paris" {
  provider = nsxt.paris
  instance_id  = data.vsphere_virtual_machine.Web01_Paris.id
  tag {
    tag   = "Web"
  }
}

data "vsphere_virtual_machine" "Web02_Paris" {
  name          = "Web02"
  datacenter_id = "${data.vsphere_datacenter.DC-Paris.id}"
}
resource "nsxt_policy_vm_tags" "web02_vm_tags_paris" {
  provider = nsxt.paris
  instance_id  = data.vsphere_virtual_machine.Web02_Paris.id
  tag {
    tag   = "Web"
  }
}

data "vsphere_virtual_machine" "DB01_Paris" {
  name         = "DB01"
  datacenter_id = "${data.vsphere_datacenter.DC-Paris.id}"
}
resource "nsxt_policy_vm_tags" "db01_vm_tags_paris" {
  provider = nsxt.paris
  instance_id  = data.vsphere_virtual_machine.DB01_Paris.id
  tag {
    tag   = "DB"
  }
}

/*
# London VMs
data "vsphere_virtual_machine" "Web01_London" {
  name         = "Web01"
  datacenter_id = "${data.vsphere_datacenter.DC-London.id}"
}
resource "nsxt_policy_vm_tags" "web01_vm_tags_london" {
  provider = nsxt.london
  instance_id  = data.vsphere_virtual_machine.Web01_London.id
  tag {
    tag   = "Web"
  }
}

data "vsphere_virtual_machine" "DB01_London" {
  name         = "DB01"
  datacenter_id = "${data.vsphere_datacenter.DC-London.id}"
}
resource "nsxt_policy_vm_tags" "db01_vm_tags_london" {
  provider = nsxt.london
  instance_id  = data.vsphere_virtual_machine.DB01_London.id
  tag {
    tag   = "DB"
  }
}
*/

