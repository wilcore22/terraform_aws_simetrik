# VPC

variable "create_vpc" {default = true}
variable "name" {default = "simetrik"}
variable "cidr" {default = "10.0.0.0/24"}
variable "instance_tenancy" {default = "default"}
variable "enable_dns_hostnames" {default = true}
variable "enable_dns_support" {default = true}
variable "tags" {default = true}

variable "name_vpc" {default = "vpc-simetrik"}

# IGW
variable "create_igw" {default = true}
variable "name_igw" {default = "igw-simetrik"}





### subnet private_subnet_cidrs1


variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

### subet public_subnet_cidrs ###

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

