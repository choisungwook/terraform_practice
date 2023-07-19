vpc_cidr = "10.0.0.0/16"

public_subnets = {
  "subnet_a" = {
    cidr = "10.0.0.0/24",
    az   = "ap-northeast-2a",
    tags = {
      Name = "public subnet a"
    }
  }
}

private_subnets = {
  "subnet_a" = {
    cidr = "10.0.100.0/24",
    az   = "ap-northeast-2a",
    tags = {
      Name = "private subnet a"
    }
  }
}
