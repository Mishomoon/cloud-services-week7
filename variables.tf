variable "instance_name" {
  description = "Name of the cPouta instance"
  type        = string
  default     = "cloud-services-week7"
}

variable "image_name" {
  description = "cPouta image name"
  type        = string
}

variable "flavor_name" {
  description = "cPouta flavor name"
  type        = string
}

variable "keypair_name" {
  description = "Name of the OpenStack SSH key pair"
  type        = string
}

variable "network_name" {
  description = "cPouta project network name"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the local SSH public key"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR address allowed to connect through SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_allowed_cidr, 0))
    error_message = "ssh_allowed_cidr must be a valid CIDR address, for example 203.0.113.10/32."
  }
}