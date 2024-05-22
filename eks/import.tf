# import {
#   to = module.eks.aws_eks_access_entry.worker_nodes["0"]
#   id = "eks-from-terraform:arn:aws:iam::467606240901:role/eks-from-terraform-eks-worker-node-role"
# }

# import {
#   to = module.eks.aws_eks_access_entry.cluster_admins["0"]
#   id = "eks-from-terraform:arn:aws:iam::467606240901:role/administrator"
# }

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association#import
# import {
#   to = module.eks.aws_eks_access_policy_association.cluster_admins
#   id = "eks-from-terraform#arn:aws:iam::467606240901:role/administrator#arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
# }
