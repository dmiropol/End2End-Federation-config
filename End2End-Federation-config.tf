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
      version = "3.1.1"
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
/* 
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
} */

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

# Edge cluster definitions
data "nsxt_policy_edge_cluster" "paris" {
  display_name = "EdgeCluster"
  site_path    = data.nsxt_policy_site.paris.path
}

data "nsxt_policy_edge_cluster" "london" {
  display_name = "EdgeCluster"
  site_path    = data.nsxt_policy_site.london.path
}

# Edge nodes definitions
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

data "nsxt_policy_service" "service_icmp" {
  display_name = "ICMP ALL"
}

data "nsxt_policy_service" "service_ssh" {
  display_name = "SSH"
}

data "nsxt_policy_service" "service_https" {
  display_name = "HTTPS"
}

data "nsxt_policy_service" "service_tcp-8443" {
  display_name = "TCP-8443"
}

data "nsxt_policy_service" "service_mysql" {
  display_name = "MySQL"
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

# T0 definitions
resource "nsxt_policy_tier0_gateway" "global_t0" {
  display_name              = "T0-ParisLondon"
  nsx_id                    = "T0-ParisLondon"
  description               = "Global Tier-0 for Paris and London locations"
  failover_mode             = "PREEMPTIVE"
  #ha_mode                   = "ACTIVE_ACTIVE"
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
  redistribution_config {
    enabled = true
    rule {
      name  = "connected"
      types = ["TIER0_STATIC", "TIER0_CONNECTED", "TIER1_CONNECTED"]
    }
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

#  BGP Neighbor 
resource "nsxt_policy_bgp_neighbor" "Paris_bgp_left" {
  display_name          = "Paris_bgp_left"
  nsx_id                = "Paris_bgp_left"
  bgp_path              = nsxt_policy_bgp_config.Paris_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 600
  keep_alive_time       = 200
  neighbor_address      = "192.168.240.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.Paris_left-intf.ip_addresses[0]]

  bfd_config {
    enabled  = true
    interval = 1000
    multiple = 3
  }
}

resource "nsxt_policy_bgp_neighbor" "Paris_bgp_right" {
  display_name          = "Paris_bgp_right"
  nsx_id                = "Paris_bgp_right"
  bgp_path              = nsxt_policy_bgp_config.Paris_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 600
  keep_alive_time       = 200
  neighbor_address      = "192.168.250.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.Paris_right-intf.ip_addresses[0]]

  bfd_config {
    enabled  = true
    interval = 1000
    multiple = 3
  }
}

resource "nsxt_policy_bgp_neighbor" "London_bgp_left" {
  display_name          = "London_bgp_left"
  nsx_id                = "London_bgp_left"
  bgp_path              = nsxt_policy_bgp_config.London_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 600
  keep_alive_time       = 200
  neighbor_address      = "192.168.243.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.London_left-intf.ip_addresses[0]]

  bfd_config {
    enabled  = true
    interval = 1000
    multiple = 3
  }
}

resource "nsxt_policy_bgp_neighbor" "London_bgp_right" {
  display_name          = "London_bgp_right"
  nsx_id                = "London_bgp_right"
  bgp_path              = nsxt_policy_bgp_config.London_global_bgp_t0.path
  graceful_restart_mode = "HELPER_ONLY"
  hold_down_time        = 600
  keep_alive_time       = 200
  neighbor_address      = "192.168.253.1"
  remote_as_num         = "200"
  source_addresses      = [nsxt_policy_tier0_gateway_interface.London_right-intf.ip_addresses[0]]

  bfd_config {
    enabled  = true
    interval = 1000
    multiple = 3
  }
}


# Global T1 definitions
resource "nsxt_policy_tier1_gateway" "paris_london_t1" {
  display_name = "T1DR-ParisLondon"
  nsx_id       = "T1DR-ParisLondon"
  tier0_path   = nsxt_policy_tier0_gateway.global_t0.path
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

# Global Segments definitions (web, app, db)
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
  tag {
    tag = "terraform"
  }
}

resource "nsxt_policy_segment" "global_app_segment" {
  display_name      = "app-seg"
  nsx_id            = "app-seg"
  connectivity_path = nsxt_policy_tier1_gateway.paris_london_t1.path
  subnet {
    cidr = "172.16.20.1/24"
  }
  advanced_config {
    connectivity = "ON"
  }
  tag {
    tag = "terraform"
  }
}

resource "nsxt_policy_segment" "global_db_segment" {
  display_name      = "db-seg"
  nsx_id            = "db-seg"
  connectivity_path = nsxt_policy_tier1_gateway.paris_london_t1.path
  subnet {
    cidr = "172.16.30.1/24"
  }
  advanced_config {
    connectivity = "ON"
  }
  tag {
    tag = "terraform"
  }
}

# Service definitions for DFW
data "nsxt_policy_service" "ssh" {
  display_name = "SSH"
}

data "nsxt_policy_service" "icmp" {
  display_name = "ICMP ALL"
}

# Security groups definitions for DFW
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
  tag {
    tag = "terraform"
  }
}

resource "nsxt_policy_group" "app_vm_group" {
  display_name = "App-VM-Group"
  nsx_id       = "App-VM-Group"
  criteria {
    condition {
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      key         = "Tag"
      value       = "App"
    }
  }
  tag {
    tag = "terraform"
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
  tag {
    tag = "terraform"
  }
}


# DFW policy definitions
resource "nsxt_policy_security_policy" "intra_tier_web_web" {
  display_name = "Intra-Tier Web-Web"
  nsx_id       = "Intra-Tier Web-Web"
  category     = "Application"
  stateful     = true
  sequence_number = "10"
  rule {
    display_name       = "Web to Web"
    source_groups      = [nsxt_policy_group.web_vm_group.path]
    destination_groups = [nsxt_policy_group.web_vm_group.path]
    scope              = [nsxt_policy_group.web_vm_group.path]
    action             = "ALLOW"
  }
  tag {
    tag = "terraform"
  }
}

resource "nsxt_policy_security_policy" "inter_tier_web_app" {
  display_name = "Inter-Tier Web-App"
  nsx_id       = "Inter-Tier Web-App"
  category     = "Application"
  stateful     = true
  sequence_number = "20"
  rule {
    display_name       = "Any to Web"
    destination_groups = [nsxt_policy_group.web_vm_group.path]
    scope              = [nsxt_policy_group.web_vm_group.path]
    services           = [data.nsxt_policy_service.service_icmp.path,data.nsxt_policy_service.service_ssh.path,data.nsxt_policy_service.service_https.path]
    action             = "ALLOW"
  }
  rule {
    display_name       = "Web to App"
    source_groups      = [nsxt_policy_group.web_vm_group.path]
    destination_groups = [nsxt_policy_group.app_vm_group.path]
    scope              = [nsxt_policy_group.web_vm_group.path,nsxt_policy_group.app_vm_group.path]
    services           = [data.nsxt_policy_service.service_tcp-8443.path,data.nsxt_policy_service.service_ssh.path]
    action             = "ALLOW"
  }
  tag {
    tag = "terraform"
  }
}

resource "nsxt_policy_security_policy" "inter_tier_app_db" {
  display_name = "Inter-Tier App-DB"
  nsx_id       = "Inter-Tier App-DB"
  category     = "Application"
  stateful     = true
  sequence_number = "30"
  rule {
    display_name       = "App to DB"
    source_groups      = [nsxt_policy_group.app_vm_group.path]
    destination_groups = [nsxt_policy_group.db_vm_group.path]
    scope              = [nsxt_policy_group.app_vm_group.path,nsxt_policy_group.db_vm_group.path]
    services           = [data.nsxt_policy_service.service_mysql.path]
    action             = "ALLOW"
  }
  tag {
    tag = "terraform"
  }
}
