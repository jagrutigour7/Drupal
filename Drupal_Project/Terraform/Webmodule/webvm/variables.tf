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
  default     = ["Webnic1", "Webnic2", "Webnic3"]
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
  default     = ["Webip1", "Webip2", "Webip3"]
}


variable "subnet_name" {
  default = "Websubnet"
}

variable "subnet_prefix" {
  default = "10.0.20.0/24"
}

variable "vm" {
  description = "Virtual Machines"
  default     = ["WebVM1", "WebVM2", "WebVM3"]
}

variable "sshkey" {
  description = "ssh_key_private"
  default     = "~/.ssh/id_rsa"
}

variable "disk" {
  default = ["webdisk1", "webdisk2", "webdisk3"]
}

variable "nodes" {
  default = 2
}
