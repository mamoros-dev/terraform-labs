variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my-terraform-ec2-basic"
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
  default     = "lab"
}

variable "ssh_ingress_cidr" {
  description = "The CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
  default     = "lab01-ec2basic"
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
  default     = null # "my-key-pair_name" # Set to null if you don't want to use a key pair
}