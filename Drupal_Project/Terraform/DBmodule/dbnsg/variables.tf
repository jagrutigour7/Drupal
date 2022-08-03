
variable "resource_group_name" {
  type        = string
  description = "Resource Group"
  default     = "myazrg"
}

variable "location" {
  description = "Location"
  default     = "South India"
}


variable "vnet_name" {
  description = "Virtual Network"
  default     = "Myazvnet"
}

variable "address_space" {
  description = "Address for vnet"
  default     = "10.0.0.0/16"
}


variable "subnet_name" {
  default = "Dbsubnet"
}

variable "subnet_prefix" {
  default = "10.0.10.0/24"
}
/*
variable "subnets" {
  type = map(any)
  default = {
    subnet_1 = {
      name             = "subnet_1"
      address_prefixes = ["10.0.10.0/24"]
    }
    subnet_2 = {
      name             = "subnet_2"
      address_prefixes = ["10.0.20.0/24"]
    }
    }
  }

variable "subnet_address" {
  type = list(string)
} */


variable "publicip_name" {
  description = "Public IPs name"
  default     = "DBip"
}

variable "network_interfaces" {
  description = "Network interfaces"
  default     = "Dbnic"
}

variable "nsg" {
  description = "Network security groups"
  default     = "DBnsg"
}