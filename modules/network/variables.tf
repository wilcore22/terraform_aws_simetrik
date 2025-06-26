# -------------------------------------------
# Common Variables
# -------------------------------------------

variable "aws_region" {
  description = "AWS infrastructure region"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tag map for the resource"
  type        = map(string)
  default     = {}
}

# -------------------------------------------
# VPC Variables
# -------------------------------------------

variable "create_vpc" {
  description = "decision to create VPC"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = ""
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

# -------------------------------------------
# Internet Gateway Variables
# -------------------------------------------

variable "create_igw" {
  description = "decision to create IGW"
  type        = bool
  default     = false
}

#######

variable "connectivity_type" {
  description = "connectivity_type"
  type        = string
  default     = "public" # "private"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = []
}

variable "name_vpc" {}
variable "name_igw" {}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = []
}




variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = []
}

variable "app_name" {
  default = ""
}



