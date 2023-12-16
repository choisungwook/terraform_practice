# 개요
* 테라폼으로 EKS 생성

<br>

# 생성 방법

* 테라폼 변수를 환경변수로 설정

```bash
# AWS profile
export TF_VAR_assume_role_arn=""
```

* 테라폼 코드 실행
```bash
terraform init
terraform plan
terraform apply # 약 15~20분 소요
````

* kubeconfig 생성

```bash
# kubeconfig 생성
aws eks update-kubeconfig --region ap-northeast-2 --name eks-from-terraform

# cluster 확인
kubectl cluster-info
```

<br>

# 삭제 방법

```bash
terrform destroy
```

<br>

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
* terraform eks addons: https://dev.to/aws-builders/install-manage-amazon-eks-add-ons-with-terraform-2dea
* terraform irsa: https://medium.com/@tech_18484/step-by-step-guide-creating-an-eks-cluster-with-terraform-resources-iam-roles-for-service-df1c5e389811
* terraform aws_iam_policy_document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
