resource "aws_security_group" "cluster" {
  name        = "eks-cluster-${var.eks-name}"
  description = "EKS Cluster security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow self EKS Cluster security group"
    self        = true
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks"
  }
}
