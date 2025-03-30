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



######## Cluster EKS ######

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.2"

  cluster_name    = "dev-cluster"
  cluster_version = "1.31"

  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

 
  cluster_endpoint_public_access = true

  
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.aws_network.aws_vpc_id
  subnet_ids               = module.aws_network.private_subnet_ids
  control_plane_subnet_ids = module.aws_network.private_subnet_ids

  
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    example = {
      
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.micro"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}