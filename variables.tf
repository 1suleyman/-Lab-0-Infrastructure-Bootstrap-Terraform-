variable "region" {
  description = "AWS region that I deploy to"
  type        = string
  default     = "eu-west-2"
}

variable "name" {
  description = "Name prefix"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the instance (your public IP /32)"
  type        = string
}
