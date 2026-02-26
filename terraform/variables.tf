variable "my_ip_cidr" {
  description = "Your public IP in CIDR form (x.x.x.x/32)"
  type        = string
  default     = "97.68.64.18/32"
}

variable "project_name" {
  description = "Prefix used for naming AWS resources"
  type        = string
  default     = "aws-reliability-lab"
}
variable "instance_type" {
  description = "EC2 instance type for ASG instances"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 Key Pair name to enable SSH"
  type        = string
}