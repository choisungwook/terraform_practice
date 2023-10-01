# 개요
* 테라폼으로 EKS 생성

# 생성 방법

```bash
# EKS 생성
terraform init
terraform apply

# kubectl config 생성
aws eks update-kubeconfig --region ap-northeast-2 --name eks-from-terraform

# cluster 확인
kubectl cluster-info
```

# 삭제 방법
```bash
terrform destroy
```

# 참고자료
* terraform module 디버깅: https://thoeny.dev/how-to-debug-in-terraform
* terraform splat: https://developer.hashicorp.com/terraform/language/expressions/splat
* terraform eks overview: https://www.linkedin.com/pulse/eks-cluster-aws-day21-vijayabalan-balakrishnan/
* terraform eks overview: https://dev.to/aws-builders/how-to-build-eks-with-terraform-54pl
* terraform eks overview: https://devpress.csdn.net/cicd/62ec845619c509286f4172fc.html
* terraform eks additional security group: https://saturncloud.io/blog/terraform-additional-security-group-for-managed-nodes-in-eks-a-comprehensive-guide/
* terraform eks aws-auth configmap: https://medium.com/@codingmaths/aws-eks-cluster-with-terraform-ebf0d2583f9a
* terraform eks aws-auth configmap: https://dev.to/fukubaka0825/manage-eks-aws-auth-configmap-with-terraform-4ndp
* terraform eks aws-auth configmap: https://github.com/cloudposse/terraform-aws-eks-cluster/blob/main/auth.tf
* terraform eks aws-auth IAM role: https://medium.com/@radha.sable25/enabling-iam-users-roles-access-on-amazon-eks-cluster-f69b485c674f
