
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

variable "nsg" {
  description = "Network security groups"
  default     = "Webnsg"
}