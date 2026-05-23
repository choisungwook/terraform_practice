# 개요

EKS를 생성하는 모듈

## Pod Identity 설정

EKS add-on이 사용하는 Pod Identity는 `eks_addons`의 `pod_identity_associations`로 설정한다.

```hcl
eks_addons = [
  {
    name                 = "aws-ebs-csi-driver"
    version              = "v1.59.0-eksbuild.1"
    configuration_values = jsonencode({})
    pod_identity_associations = [
      {
        role_arn        = aws_iam_role.ebs_csi_driver.arn
        service_account = "ebs-csi-controller-sa"
      }
    ]
  }
]
```

일반 workload ServiceAccount가 사용하는 Pod Identity는 `pod_identity_associations`로 설정한다.

```hcl
pod_identity_associations = {
  catalog = {
    namespace       = "default"
    service_account = "catalog-sa"
    role_arn        = aws_iam_role.catalog.arn
  }
}
```
