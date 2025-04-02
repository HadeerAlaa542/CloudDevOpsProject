# main.tf
module "network" {
  source      = "./modules/network"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
}

module "master_server" {
  source            = "./modules/server"
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id
  instance_name     = "master"
  key_name          = "ivolve-key"
  instance_type     = "t2.small" 
  volume_size       = 15


}

module "slave_server" {
  source            = "./modules/server"
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id
  instance_name     = "slave"
  key_name          = "ivolve-key"
  instance_type     = "t2.xlarge" 
  volume_size       = 20
}

module "cloudwatch_master" {
  source      = "./modules/cloudwatch"
  instance_id = module.master_server.instance_id
}

module "cloudwatch_slave" {
  source      = "./modules/cloudwatch"
  instance_id = module.slave_server.instance_id
}
