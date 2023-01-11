#### REGION VAR
variable "region_gra" {
  type = string
  default = "GRA11"
}
variable "region_sbg" {
  type = string
  default = "SBG5"
}
#### INSTANCE VAR
variable "instance_name_gra" {
  type = string
  default = "backend_eductive07_gra"
}
variable "instance_name_gra_front" {
  type = string
  default = "front_eductive07"
}
variable "instance_name_sbg" {
  type = string
  default = "backend_eductive07_sbg"
}
variable "image_name" {
  type = string
  default = "Debian 11"
}
variable "flavor_name" {
  type = string
  default = "s1-2"
}
variable "service_name" {
  type    = string
}
#### NETWORKS VAR
variable "vlan_id" {
  type    = number
  default = 07
}
variable "vlan_dhcp_start" {
  type = string
  default = "192.168.7.100"
}
variable "vlan_dhcp_end" {
  type = string
  default = "192.168.7.200"
}
variable "vlan_dhcp_network" {
  type = string
  default = "192.168.7.0/24"
}

#### DB VAR
variable "db_vars" {
  type = map
  default = {
    service_name = "9957f50cea694f13b26cc064d04b2e95"
    description  = "mysql_db_eductive07"
    engine       = "mysql"
    version      = "8"
    plan         = "essential"
    flavor       = "db1-4"
    ip_restriction = "0.0.0.0/0"
    region       = "GRA"
  }
}
