module "vpc" {
  source = "../../modules/vpc"

  name = "microservices-eks"
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  private_subnet_ids = module.vpc.private_subnet_ids

  depends_on = [module.vpc]
}
