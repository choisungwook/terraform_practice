module "vpc" {
  source = "./module/vpc"

  eks_cluster_name = var.eks_cluster_name

  vpc_cidr = "10.0.0.0/16"
  public_subnets = {
    "subnet_a1" = {
      cidr = "10.0.10.0/24",
      az   = "ap-northeast-2a",
      tags = {
        Name = "public-subnet-a1"
      }
    },
    "subnet_b1" = {
      cidr = "10.0.11.0/24",
      az   = "ap-northeast-2c",
      tags = {
        Name = "public-subnet-c1"
      }
    }
  }
  private_subnets = {
    "subnet_a1" = {
      cidr = "10.0.100.0/24",
      az   = "ap-northeast-2a",
      tags = {
        Name = "private-subnet-a1"
      }
    },
    "subnet_b1" = {
      cidr = "10.0.101.0/24",
      az   = "ap-northeast-2c",
      tags = {
        Name = "private-subnet-c1"
      }
    }
  }
}

module "eks" {
  source = "./module/eks"

  eks_cluster_name      = var.eks_cluster_name
  eks_version           = var.eks_version
  oidc_provider_enabled = var.oidc_provider_enabled

  vpc_id                  = module.vpc.vpc_id
  private_subnets_ids     = module.vpc.private_subnets_ids
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access

  # 아래 명령어를 실행하여 addon version을 설정하세요
  # aws eks describe-addon-versions --kubernetes-version {eks_verison} --addon-name {addon_name} --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' --output table
  eks_addons = [
    # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-kube-proxy.html
    {
      name                 = "kube-proxy"
      version              = "v1.29.0-eksbuild.3"
      configuration_values = jsonencode({})
    },
    # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-vpc-cni.html
    {
      name                 = "vpc-cni"
      version              = "v1.16.2-eksbuild.1"
      configuration_values = jsonencode({})
    },
    # https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/managing-coredns.html
    {
      name                 = "coredns"
      version              = "v1.11.1-eksbuild.6"
      configuration_values = jsonencode({})
    }
  ]

  managed_node_groups = var.managed_node_groups

  // IRSA role 생성 여부
  karpenter_enabled      = true
  alb_controller_enabled = true
  external_dns_enabled   = true
  enable_amp             = var.enable_amp

  // EKS access entry 설정
  aws_auth_admin_roles = [
    var.assume_role_arn
  ]
}

data "local_file" "managed_prometheus_config" {
  count = var.enable_amp ? 1 : 0

  filename = "scrape_configuration.yaml"
}

module "managed_prometheus" {
  count = var.enable_amp ? 1 : 0

  source = "./module/managed_prometheus"

  eks_cluster_name            = var.eks_cluster_name
  eks_cluster_arn             = module.eks.eks_cluster_arn
  scrap_configuration_content = data.local_file.managed_prometheus_config[0].content
  private_subnets_ids         = module.vpc.private_subnets_ids
}
