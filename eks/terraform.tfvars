eks_cluster_name = "eks-from-terraform"
eks_version      = "1.34"

# EKS 접근 유형
endpoint_private_access = true
# public_access가 false이면, terraform qapply를 실행한 host가 private subnet이 접근 가능해야 합니다.
endpoint_public_access = true

# Amazon Managed Prometheus 설치 여부
enable_amp = false

######################################################################
# EKS control plane
# Ref: https://aws.amazon.com/ko/blogs/tech/eks-advanced-control-plane/
######################################################################

# Provisioned control plane tier: standard, tier-xl, tier-2xl, tier-4xl, tier-8xl
# standard 외 tier는 추가 요금이 발생합니다.
control_plane_scaling_tier = "standard"

# kube-apiserver
# event_ttl: 10m ~ 60m, service_node_port_range: 10260 ~ 32767
kube_api_server_config = {
  event_ttl = "1h"
  service_node_port_range = {
    min_port = 30000
    max_port = 32767
  }
}

# kube-controller-manager
# horizontal_pod_autoscaler_sync_period: 10s ~ 15s, tier-xl 이상에서만 설정 가능 (standard는 null)
# terminated_pod_gc_threshold: 0 ~ 12500
kube_controller_manager_config = {
  horizontal_pod_autoscaler_sync_period = null
  terminated_pod_gc_threshold           = 12500
}

# kube-scheduler NodeResourcesFit
# scoring_strategy_type: LeastAllocated(분산 배치) 또는 MostAllocated(bin packing)
# scoring_resources weight: 1 ~ 100
kube_scheduler_config = {
  scoring_strategy_type = "LeastAllocated"
  scoring_resources = [
    {
      name   = "cpu"
      weight = 1
    },
    {
      name   = "memory"
      weight = 1
    }
  ]
}

######################################################################
# EKS auto Mode
######################################################################

auto_mode_enabled = false

cluster_compute_config = {
  node_pools = [
    # "general-purpose", "system"
  ]
}

######################################################################
# Managed Node Groups
######################################################################

managed_node_groups = {
  "managed-node-group-a" = {
    node_group_name = "managed-node-group-a",
    instance_types  = ["t3.medium"],
    capacity_type   = "SPOT",
    release_version = "1.34.2-20251120",
    disk_size       = 20,
    desired_size    = 2,
    max_size        = 2,
    min_size        = 2,
    labels = {
      "node-type" = "managed-node-group-a-with-spot"
    }
  },
  # labels, taint 설정 예
  # "managed-node-group-b" = {
  #   node_group_name = "managed-node-group-b",
  #   instance_types  = ["t3.medium"],
  #   capacity_type   = "ON_DEMAND",
  #   release_version = "1.34.2-20251120",
  #   disk_size       = 20,
  #   desired_size    = 1,
  #   max_size        = 1,
  #   min_size        = 1,
  #   labels         = {
  #     "node-type" = "managed-node-group-b"
  #   }
  #   taints = [
  #     {
  #       key    = "node-type"
  #       value  = "managed-node-group-b"
  #       effect = "NO_SCHEDULE"
  #     }
  #   ]
  # },
  # GPU 노드 예제
  # "managed-node-group-gpu-a" = {
  #   node_group_name = "managed-node-group-gpu-a",
  #   instance_types  = ["g6.xlarge"],
  #   capacity_type   = "ON_DEMAND",
  #   # EKS nvidia GPU optimized AMI
  #   release_version = "1.34.2-20251120",
  #   ami_type      = "AL2023_x86_64_NVIDIA",
  #   disk_size       = 20,
  #   desired_size    = 1,
  #   max_size        = 1,
  #   min_size        = 1,
  #   labels = {
  #     "nvidia.com/gpu" = "true",
  #     "node-type" = "managed-node-group-gpu-a"
  #   }
  #   taints = [
  #     {
  #       key    = "nvidia.com/gpu"
  #       value  = "true"
  #       effect = "NO_SCHEDULE"
  #     }
  #   ]
  # },
}

######################################################################
# VPC
######################################################################

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
    az   = "ap-northeast-2b",
    tags = {
      Name = "public-subnet-b1"
    }
  },
  "subnet_c1" = {
    cidr = "10.0.12.0/24",
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
