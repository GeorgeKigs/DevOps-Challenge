locals {
  region  = "eu-central-1"
  project = "challenge"
  tags = {
    "Environment"   = "sandbox"
    "Owner"         = "gndungu"
    "BusinessOwner" = "Digital Engineering"
    "Project"       = "devops-challenge"
    "CreatedBy"     = "George Ndungu"
  }
}



module "networking" {
  source = "./modules/networking"
  # create critical resources
  create_igw                 = true
  create_vpc                 = true
  cidr_block                 = "172.31.0.0/16"
  public_cidr_block          = ["172.31.149.0/24"]
  private_cidr_block         = ["172.31.150.0/24", "172.31.151.0/24", "172.31.152.0/24"] # data plane and internal network.
  cidr_block_sg_lb           = "172.31.149.0/24"
  cidr_block_sg_db           = "172.31.151.0/24"
  cidr_block_sg_microservice = "172.31.150.0/24"
  region                     = local.region
  project                    = local.project
  tags                       = local.tags
}

# outputs:
# vpc_id
# internet_gateway_id
# public_subnet_id
# private_subnet_id
# security_group_id


module "misc" {
  source   = "./modules/misc"
  key_name = "key_pair.pub"
}

module "database" {
  source = "./modules/rds"
  # create critical resources

  region                 = local.region
  project                = local.project
  tags                   = local.tags
  name                   = "jumia_phone_validator"
  instance_class         = "db.t3.micro"
  username               = "jumia"
  password               = var.password
  vpc_security_group_ids = [module.networking.main_security_group_id, module.networking.db_security_group_id]
  subnet_ids             = [module.networking.private_subnet_id.1, module.networking.private_subnet_id.2]
  disk_size              = 10

}

module "public_node" {
  source = "./modules/ec2"
  # create critical resources
  os_details       = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  os_details_owner = "099720109477"
  subnet_id        = module.networking.public_subnet_id.0
  ec2_count            = 1
  private_ip       = ["172.31.149.4"]
  instance_type    = "t3.medium"
  disk_size        = 150
  key_name         = module.misc.key_pair
  security_group   = [module.networking.main_security_group_id, module.networking.lb_security_group_id]

  region  = local.region
  project = local.project
  tags    = local.tags
}

module "private_node" {
  source = "./modules/ec2"
  # create critical resources
  os_details       = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  os_details_owner = "099720109477"
  subnet_id        = module.networking.private_subnet_id.0
  ec2_count            = 2
  private_ip       = ["172.31.150.10", "172.31.150.11"]
  instance_type    = "t3.medium"
  disk_size        = 150
  key_name         = module.misc.key_pair
  security_group = [
    module.networking.main_security_group_id,
    module.networking.micro_security_group_id
  ]

  region  = local.region
  project = local.project
  tags    = local.tags
}

# module "eks_cluster" {
#   source = "./modules/eks_cluster"

#   # get this arns using data 
#   cluster_policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   service_policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"

#   # create 
#   flux_kustomize_sops_kms_arn = module.cloud9.flux-kms-arn
#   eks_version             = "1.27"
#   endpoint_private_access = true
#   endpoint_public_access  = false
#   vpc_id              = module.networking.vpc_id
#   private_subnet_ids  = module.networking.private_subnet_id
#   public_access_cidrs = []
#   project      = local.project
#   cloud9_sg_id = ["${module.cloud9.cloud9_sg_id}"]

#   region = local.region
#   tags   = local.tags
# }

# module "eks_nodegroup" {
#   source  = "./modules/eks_nodegroup"
#   region  = local.region
#   tags    = local.tags
#   project = local.project

#   eks_cluster_id         = module.eks_cluster.eks_cluster_id
#   eks_cluster_name       = module.eks_cluster.eks_cluster_name
#   eks_worker_subnet_id   = module.networking.private_subnet_id
#   ami_type               = "AL2_x86_64"
#   capacity_type          = "ON_DEMAND"
#   create_launch_template = true
#   desired_size           = "2"

#   public-key = "id_rsa.pub"

#   instance_type_lt       = "t3.micro"
#   lt_version             = "$Latest"
#   max_size               = "3"
#   min_size               = "2"
#   node_group_name        = "nodegroup"
#   volume_size            = "30"
#   volume_type            = "gp3"

#   addons = [
#     {
#       name    = "coredns"
#       version = "v1.10.1-eksbuild.1"
#     }
#   ]

# }