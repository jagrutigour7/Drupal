variable "resource_group_name" {
  type        = string
  description = "Resource Group"
  default     = "myazrg"
}

variable "location" {
  description = "Location"
  default     = "South India"
}

variable "network_interfaces" {
  description = "Network interfaces"
  default     = "Dbnic"
}


variable "vnet_name" {
  description = "Virtual Network"
  default     = "Myazvnet"
}

variable "address_space" {
  description = "Address for vnet"
  default     = "10.0.0.0/16"
}

variable "publicip_name" {
  description = "Public IPs name"
  default     = "DBip"
}


variable "subnet_name" {
  default = "Dbsubnet"
}

variable "subnet_prefix" {
  default = "10.0.10.0/24"
}

variable "vm" {
  description = "Virtual Machines"
  default     = "DBVM"
}


variable "sshkey" {
  default = "./dbkey.pem"
}