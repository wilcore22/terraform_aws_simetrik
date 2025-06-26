#### create vpc #####
module "aws_network" {
  source = "./modules/network"
  create_vpc           = var.create_vpc
  create_igw           = var.create_igw
  name                 = var.name
  cidr                 = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  public_subnet_cidrs      = var.public_subnet_cidrs
  azs                      = var.azs
  private_subnet_cidrs      = var.private_subnet_cidrs
  name_igw                 = var.name_igw
  name_vpc                 = var.name_vpc

}


### dynamo ##
module "aws_dynamo"{
source = "./modules/dynamo"
app_name = var.app_name
}


##### ecs ####

module "aws_ecs_alb"{
source = "./modules/ecs-alb"
app_name = var.app_name
vpc_id = module.aws_network.aws_vpc_id
subnet_public = module.aws_network.public_subnet_ids
security_group_alb = module.aws_network.aws_security_group_alb
subnet_private = module.aws_network.private_subnet_ids
security_group_ecs = module.aws_network.aws_security_group_ecs
}


module "aws_cache"{
source = "./modules/cache"
app_name = var.app_name
vpc_id = module.aws_network.aws_vpc_id
elasticache_subnet_group_redis = module.aws_network.aws_elasticache_subnet_group_redis
sg_ecs = module.aws_network.aws_security_group_ecs
}


##### ecs ####

module "aws_s3_cloudfront"{
source = "./modules/s3-cloudfront"
app_name = var.app_name
}



