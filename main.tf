data "aws_region" "current" {}

# Transit
module "aws_syd_transit01" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.0.1"

  name                   = "aws-syd-transit01"
  cloud                  = "aws"
  region                 = data.aws_region.current.name
  cidr                   = cidrsubnet(var.supernet, 7, 0)
  account                = var.aws_account
  instance_size          = "t2.micro" #firenet > "c5.xlarge"
  ha_gw                  = false
  single_az_ha           = false
  enable_segmentation    = true
  enable_transit_firenet = false

  local_as_number             = 65001
  learned_cidr_approval       = true
  learned_cidrs_approval_mode = "gateway"
}

# Spoke1
module "aws_syd_spoke1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.2"

  name          = "aws-syd-spoke1"
  cloud         = "AWS"
  cidr          = cidrsubnet(var.supernet, 8, 11)
  region        = data.aws_region.current.name
  account       = var.aws_account
  instance_size = "t2.micro"
  single_az_ha  = false
  ha_gw         = false
  #attached      = false
  transit_gw = module.aws_syd_transit01.transit_gateway.gw_name
}

# Spoke2
module "aws_syd_spoke2" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.2"

  name          = "aws-syd-spoke2"
  cloud         = "AWS"
  cidr          = cidrsubnet(var.supernet, 8, 12)
  region        = data.aws_region.current.name
  account       = var.aws_account
  instance_size = "t2.micro"
  single_az_ha  = false
  ha_gw         = false
  #attached      = false
  transit_gw = module.aws_syd_transit01.transit_gateway.gw_name
}

#############
# Instances #
#############

# Create Public EC2 instances in Spoke1 for each az
module "spoke1_public_ec2" {
  for_each = { for k, v in module.aws_syd_spoke1.vpc.public_subnets : k => v }

  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  random_suffix                  = false
  instance_hostname              = "spoke1-public-ec2-${element(split("-", each.value.name), length(split("-", each.value.name)) - 1)}" # get last element of the public_subnets name which is the az suffix 
  vpc_id                         = module.aws_syd_spoke1.vpc.vpc_id
  subnet_id                      = each.value.subnet_id
  key_name                       = "ec2_keypair"
  associate_public_ip_address    = true
  enable_password_authentication = true
  random_password                = false
  instance_username              = var.instance_username
  instance_password              = var.instance_password
}

# Create Private EC2 instances in Spoke1 for each az
module "spoke1_private_ec2" {
  for_each = { for k, v in module.aws_syd_spoke1.vpc.private_subnets : k => v }

  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  random_suffix                  = false
  instance_hostname              = "spoke1-private-ec2-${element(split("-", each.value.name), length(split("-", each.value.name)) - 1)}" # get last element of the public_subnets name which is the az suffix 
  vpc_id                         = module.aws_syd_spoke1.vpc.vpc_id
  subnet_id                      = each.value.subnet_id
  key_name                       = "ec2_keypair"
  associate_public_ip_address    = true
  enable_password_authentication = true
  random_password                = false
  instance_username              = var.instance_username
  instance_password              = var.instance_password
}

# Create Public EC2 instances in Spoke2 for each az
module "spoke2_public_ec2" {
  for_each = { for k, v in module.aws_syd_spoke2.vpc.public_subnets : k => v }

  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  random_suffix                  = false
  instance_hostname              = "spoke2-public-ec2-${element(split("-", each.value.name), length(split("-", each.value.name)) - 1)}" # get last element of the public_subnets name which is the az suffix 
  vpc_id                         = module.aws_syd_spoke2.vpc.vpc_id
  subnet_id                      = each.value.subnet_id
  key_name                       = "ec2_keypair"
  associate_public_ip_address    = true
  enable_password_authentication = true
  random_password                = false
  instance_username              = var.instance_username
  instance_password              = var.instance_password
}

# Create Private EC2 instances in Spoke2 for each az
module "spoke2_private_ec2" {
  for_each = { for k, v in module.aws_syd_spoke2.vpc.private_subnets : k => v }

  source  = "bayupw/amazon-linux-2/aws"
  version = "1.0.0"

  random_suffix                  = false
  instance_hostname              = "spoke2-private-ec2-${element(split("-", each.value.name), length(split("-", each.value.name)) - 1)}" # get last element of the public_subnets name which is the az suffix 
  vpc_id                         = module.aws_syd_spoke2.vpc.vpc_id
  subnet_id                      = each.value.subnet_id
  key_name                       = "ec2_keypair"
  associate_public_ip_address    = true
  enable_password_authentication = true
  random_password                = false
  instance_username              = var.instance_username
  instance_password              = var.instance_password
}