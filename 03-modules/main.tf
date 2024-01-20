/* Estamos criando um novo módulo. Além disso, conseguimos inputar as variáveis que
estamos utilizando no módulo. */

terraform {
  required_version = ">= 0.13.1"
  required_providers {
    aws = ">=3.54.0"
    local = ">=2.1.0"
  }
  backend "s3" {
    bucket = "myfcbucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

module "new-vpc" {
  source         = "./vpc"
  prefix         = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" { //Abaixo, temos todas as variáveis que estão sendo utilizadas no módulo "eks".
  source         = "./eks"
  prefix         = var.prefix
  vpc_id         = module.new-vpc.vpc_id
  cluster_name   = var.cluster_name
  retention_days = var.retention_days
  subnet_ids     = module.new-vpc.subnet_ids
  desired_size   = var.desired_size
  max_size       = var.max_size
  min_size       = var.min_size
  vpc_cidr_block = var.vpc_cidr_block
}