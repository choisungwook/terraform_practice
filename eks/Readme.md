# Terraform EKS Quick Start

## 개요

이 저장소는 로컬 테스트용으로 사용하는 Terraform EKS 모듈입니다.
처음 시작하는 사람이 EKS 클러스터를 빠르게 생성하고, kubeconfig를 설정한 뒤, 기본 동작을 확인하는 흐름을 기준으로 정리했습니다.

프로덕션 환경에는 이 예제를 그대로 사용하지 마세요.
프로덕션에서는 EKS Blueprints 같은 검증된 구성을 먼저 검토하는 것을 권장합니다.

## TL;DR

- `TF_VAR_assume_role_arn`에 EKS를 생성할 AWS IAM role ARN을 설정합니다.
- `terraform.tfvars`에서 `eks_cluster_name`과 `eks_version`을 확인합니다.
- `main.tf`에서 `eks_addons`가 EKS 버전과 호환되는지 확인합니다.
- `terraform init`, `terraform plan`, `terraform apply` 순서로 클러스터를 생성합니다.
- `aws eks update-kubeconfig`로 kubeconfig를 생성한 뒤 `kubectl cluster-info`로 접속을 확인합니다.

## 준비

### 1. AWS IAM role 준비

이 모듈은 EKS를 생성하고 관리할 AWS IAM role이 필요합니다.
Terraform 변수 `assume_role_arn`에 해당 role ARN을 전달해야 합니다.

환경 변수로 설정하려면 아래처럼 입력합니다.

```bash
export TF_VAR_assume_role_arn="{your iam role arn}"
```

AWS CLI profile은 아래처럼 role을 AssumeRole 할 수 있어야 합니다.

```bash
cat ~/.aws/config
```

```text
[default]
region = ap-northeast-2
output = json

[profile eks]
region = ap-northeast-2
role_arn = {your iam role arn}
source_profile = default
```

### 2. EKS 클러스터 이름 설정

`terraform.tfvars`에서 `eks_cluster_name`을 설정합니다.
이 값은 EKS 이름과 AWS VPC subnet 등 관련 리소스 tag에 사용됩니다.

```hcl
eks_cluster_name = "eks-from-terraform"
```

### 3. EKS 버전 설정

`terraform.tfvars`에서 `eks_version`을 설정합니다.

```hcl
eks_version = "1.34"
```

### 4. EKS addon 설정

`main.tf`의 `eks_addons` 값을 확인합니다.
EKS addon 버전은 EKS 클러스터 버전과 호환되어야 합니다.

확인 필요: 현재 `terraform.tfvars`의 `eks_version`과 `main.tf`의 `eks_addons` 예시 버전이 같은 EKS minor version을 기준으로 맞춰져 있는지 적용 전에 다시 확인하세요.

addon 버전은 아래 명령어로 확인할 수 있습니다.

```bash
aws eks describe-addon-versions \
  --kubernetes-version {eks_version} \
  --addon-name {addon_name} \
  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' \
  --output table
```

VPC CNI는 node 생성 전에 설치되도록 `before_compute = true`를 설정하세요.
node 생성 후에 VPC CNI를 설치하면 클러스터 생성이 멈추는 상황이 생길 수 있습니다.

```hcl
eks_addons = [
  {
    name                 = "vpc-cni"
    version              = "v1.19.2-eksbuild.5"
    before_compute       = true
    configuration_values = jsonencode({})
  },
]
```

## EKS 생성 방법

### 1. Terraform 실행

```bash
terraform init
terraform plan
terraform apply
```

`terraform apply`는 약 15~20분 정도 걸릴 수 있습니다.

### 2. kubeconfig 생성

```bash
export AWS_PROFILE=eks
export EKS_NAME=eks-from-terraform

aws eks update-kubeconfig --region ap-northeast-2 --name "$EKS_NAME"
```

### 3. kubectl 접속 확인

```bash
kubectl cluster-info
```

## 옵션

### Amazon Managed Service for Prometheus로 EKS 메트릭 수집

1. `terraform.tfvars`에서 `enable_amp`를 `true`로 설정합니다.
2. `terraform apply`를 실행합니다. 약 20분 정도 걸릴 수 있습니다.
3. [Amazon Managed Service for Prometheus 연동 문서](./Amazon_prometheus.md)를 참고해 Grafana와 Amazon Managed Service for Prometheus를 연동합니다.

```hcl
enable_amp = true
```

### EKS Auto Mode 활성화

EKS Auto Mode를 사용하려면 `terraform.tfvars`에서 `auto_mode_enabled`를 `true`로 설정합니다.

```hcl
auto_mode_enabled = true
```

EKS Auto Mode를 사용할 때는 `main.tf`의 `eks_addons` 호환 여부를 먼저 확인하세요.
호환 여부를 확인하지 못했다면 addon을 직접 설치하지 않는 것을 권장합니다.

```hcl
eks_addons = [
  ...
]
```

## 삭제 방법

클러스터와 관련 리소스를 삭제하려면 아래 명령어를 실행합니다.

```bash
terraform destroy
```

## 참고자료

- Terraform module 디버깅: https://thoeny.dev/how-to-debug-in-terraform
- Terraform splat: https://developer.hashicorp.com/terraform/language/expressions/splat
- Terraform EKS overview: https://www.linkedin.com/pulse/eks-cluster-aws-day21-vijayabalan-balakrishnan/
- Terraform EKS overview: https://dev.to/aws-builders/how-to-build-eks-with-terraform-54pl
- Terraform EKS overview: https://devpress.csdn.net/cicd/62ec845619c509286f4172fc.html
- Terraform EKS additional security group: https://saturncloud.io/blog/terraform-additional-security-group-for-managed-nodes-in-eks-a-comprehensive-guide/
- Terraform EKS aws-auth ConfigMap: https://medium.com/@codingmaths/aws-eks-cluster-with-terraform-ebf0d2583f9a
- Terraform EKS aws-auth ConfigMap: https://dev.to/fukubaka0825/manage-eks-aws-auth-configmap-with-terraform-4ndp
- Terraform EKS aws-auth ConfigMap: https://github.com/cloudposse/terraform-aws-eks-cluster/blob/main/auth.tf
- Terraform EKS aws-auth IAM role: https://medium.com/@radha.sable25/enabling-iam-users-roles-access-on-amazon-eks-cluster-f69b485c674f
- Terraform EKS addons: https://dev.to/aws-builders/install-manage-amazon-eks-add-ons-with-terraform-2dea
- Terraform IRSA: https://medium.com/@tech_18484/step-by-step-guide-creating-an-eks-cluster-with-terraform-resources-iam-roles-for-service-df1c5e389811
- Terraform aws_iam_policy_document: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment
- Migrate from aws-auth to access entry: https://fixit-xdu.medium.com/aws-eks-access-entry-4a7e25ed6c3a
- Migrate from aws-auth to access entry: https://opsinsights.dev/simplifying-access-entries-in-eks-a-guide
- AWS Docs - access entry: https://docs.aws.amazon.com/eks/latest/userguide/migrating-access-entries.html
