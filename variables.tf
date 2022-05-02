variable "supernet" {
  type    = string
  default = "10.1.0.0/16"
}

variable "aws_account" {
  type    = string
  default = "aws-account"
}

variable "key_name" {
  description = "Existing EC2 Key Pair"
  type        = string
  default     = "ec2_keypair"
}