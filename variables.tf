# VPC Name
variable "vpc_name" {
  description = "This Value is added in front of resources."
  default     = "tf"
  type        = string
}

# Instance Tenancy Type - Default, Dedicated
variable "instance_tenancy" {
  description = "It determines whether your instances run on hardware that is shared with other AWS customers (Default/Dedicated)"
  default     = "Default"
  type        = string
}

# VPC CIDR Range
variable "vpc_cidr_block" {
  description = "VPC CIDR Block Range"
  type        = string
}

# Create Public Subnets
variable "pub_subnet_count" {
  default     = 1
  description = "How many public subnets you want to create"
  type        = number
}

# Create Private Subnets
variable "pvt_subnet_count" {
  default     = 1
  description = "How many private subnets you want to create"
  type        = number
}

# Public Subnet CIDR Blocks
variable "pub_subnet_cidr_block" {
  description = "List of CIDR blocks for public subnets."
  type        = list(string)
}

# Private Subnet CIDR Blocks
variable "pvt_subnet_cidr_block" {
  description = "List of CIDR blocks for private subnets."
  type        = list(string)
}

# Availability Zones
variable "azs" {
  description = "List of Availability Zones for your subnets."
  type        = list(string)
}

# Kubernetes Cluster Name
variable "cluster_name" {
  description = "Kubernetes Cluster Name"
  default     = "Test"
  type        = string
}


# List of allowed ports - SSH, HTTP, HTTPS, SonarQube, Jenkins
variable "allowed_ports" {
  description = "List of ports to allow inbound traffic for"
  type        = list(number)
  default     = [22, 80, 443, 9001, 8080]
}

# Environment Type
variable "environment" {
  description = "The environment for which the security group is being created"
  type        = string
  default     = "prod"
}
