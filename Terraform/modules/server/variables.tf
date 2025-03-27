variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}
variable "ivolve-key" {
  description = "Name of the SSH key pair"
  type        = string
}
variable "instance_type" {  
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"  
}