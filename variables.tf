variable "supernet" {
  type    = string
  default = "10.1.0.0/16"
}

variable "aws_account" {
  type    = string
  default = "aws-account"
}

variable "instance_username" {
  description = "EC2 instance username"
  type        = string
  default     = "ec2-user"
}

variable "instance_password" {
  description = "EC2 instance password"
  type        = string
  default     = "Aviatrix123#"
}

variable "key_name" {
  description = "Existing EC2 Key Pair"
  type        = string
  default     = "ec2_keypair"
}