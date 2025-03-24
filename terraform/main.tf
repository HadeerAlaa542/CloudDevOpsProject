module "network" {
  source      = "./modules/network"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "ec2" {
  source           = "./modules/ec2"
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  subnet_id        = module.network.subnet_id
  security_group_id = module.security.security_group_id
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

