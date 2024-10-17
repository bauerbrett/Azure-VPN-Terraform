# modules/azure_vm/variables.tf

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "location" {
  description = "The location where the VM will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "image_publisher" {
  description = "The image publisher (e.g., Canonical for Ubuntu or MicrosoftWindowsServer for Windows)"
  type        = string
}

variable "image_offer" {
  description = "The image offer (e.g., UbuntuServer for Ubuntu or WindowsServer for Windows)"
  type        = string
}

variable "image_sku" {
  description = "The image SKU (e.g., 18.04-LTS for Ubuntu or 2019-Datacenter for Windows)"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "The ID of the subnet in which the NIC will be placed"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}
