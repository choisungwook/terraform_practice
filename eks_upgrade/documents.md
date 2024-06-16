# 업그레이드 과정 기록

* control plane이 업그레이드 되면 OIDC connect가 재생성된다. pod를 재부팅하지 않아도 IRSA가 잘 인식된다.

![](./imgs/upgrade_eks_terraform_plan.png)

![](./imgs/upgrade_eks_terraform_apply.png)

* AWS console에서는 updating으로 표시된다.

![](./imgs/upgrade_eks_console.png)

* 업그레이드 하는 동안 기존 pod는 영향을 미치지 않는다.
