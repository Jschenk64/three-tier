variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.49.0.0/16"
}

variable "pub_subnet1_cidr" {
  description = "The CIDR block for the first public subnet"
  default     = "10.49.150.0/24"
}

variable "pub_subnet2_cidr" {
  description = "The CIDR block for the second public subnet"
  default     = "10.49.151.0/24"
}

variable "priv_subnet1_cidr" {
  description = "The CIDR block for the first private subnet"
  default     = "10.49.152.0/24"
}

variable "priv_subnet2_cidr" {
  description = "The CIDR block for the second private subnet"
  default     = "10.49.153.0/24"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  default     = "ami-0084a47cc718c111a"
}

variable "instance_type" {
  description = "The instance type for EC2 instances"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key name for SSH access to EC2 instances"
  default     = "eng-de"
}