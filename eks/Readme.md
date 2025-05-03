# 개요

* 악분이 로컬에서 테스트용도로 사용하는 테라폼 EKS 모듈입니다. 테스트용도로만 사용하고 프로덕션에 사용하지 마세요.
* 프로덕션은 EKS Blueprint 등을 사용하시길 바랍니다.

# 준비

## 1. AWS IAM role 준비

* 제가 만든 모듈은 EKS를 생성하고 관리할 AWS IAM role이 필요합니다.
* AWS IAM role은 테라폼 변수 "assume_role_arn"로 관리합니다.
* assume_role_arn에 설정할 IAM role은 환경변수로 설정할 수 있습니다.

```bash
# AWS profile
export TF_VAR_assume_role_arn=""
```

## 2. EKS 버전 설정

* terraform.tfvarfs에 eks_version 변수에 EKS 버전을 설정합니ㅏㄷ.

```sh
eks_version = 1.32
```

## 3. EKS addon 설정

* main.tf에 eks_addons 값을 설정합니다. EKS버전에 맞는 addons를 설정해야 합니다.
* EKS addons은 생성/수정/삭제 timeout이 5분으로 설정되어 있습니다.

> VPC CNI는 before_compute=true 옵션을 설정해주세요. VPC CNI는 노드 생성 후에 설치할 경우, hang이 걸릴 확률이 높습니다

```sh
eks_addons = [
  {
      name                 = "vpc-cni"
      version              = "v1.19.2-eksbuild.5"
      before_compute       = true
      configuration_values = jsonencode({})
    },
]
```

## 4. EKs cluster 이름 설정

* terraform.tfvars의 eks_cluster_name에 EKS 이름을 설정합니다.
8 eks_cluster_name 변수는 AWS VPC subnet 등 리소스 tag에 설정됩니다.

# EKS 생성방법

* 테라폼 apply

```bash
terraform init
terraform plan
terraform apply # 약 15~20분 소요
````

# kube context 생성

```bash
# kubeconfig 생성
aws eks update-kubeconfig --region ap-northeast-2 --name eks-from-terraform

# cluster 확인
kubectl cluster-info
```

# (옵션) Amazon prometheus를 사용하여 EKS 메트릭 수집

1. 테라폼 변수에서 enable_amp를 true로 설정
2. terraform apply(약 20분 소요)
3. [문서](./Amazon_prometheus.md)를 참고하여 grafana<->Amazon proemtheus 연동

# (옵션) EKS auto mode 활성화

* EKS auto mode를 사용한다면, terraform.tfvars에서 auto_mode_enabled를 true로 설정합니다.
* 그리고, main.tf에 있는 EKS addon 호환여부를 확인하세요. 만약 호환여부를 모른다면, 애드온을 설치하지 않은 것을 권장드립니다.

```sh
# terraform.tfvars
auto_mode_enabled = true
```

```sh
# main.tf
eks_addons = [
  ...
]
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
* terraform eks addons: https://dev.to/aws-builders/install-manage-amazon-eks-add-ons-with-terraform-2dea
* terraform irsa: https://medium.com/@tech_18484/step-by-step-guide-creating-an-eks-cluster-with-terraform-resources-iam-roles-for-service-df1c5e389811
* terraform aws_iam_policy_document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
* migrate from aws-auth to access entry: https://fixit-xdu.medium.com/aws-eks-access-entry-4a7e25ed6c3a
* migrate from aws-auth to access entry: https://opsinsights.dev/simplifying-access-entries-in-eks-a-guide
* aws docs - accesss entry: https://docs.aws.amazon.com/eks/latest/userguide/migrating-access-entries.html
