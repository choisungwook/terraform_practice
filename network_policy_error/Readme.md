# 개요
* EKS network policy 버그 재현
* 버그 증상: 특정 pod 또는 kubernetes service clusterIP를 사용하여 특정 pod호출이 안됨

# 테라폼 설치
* [EKS 설치 문서](../eks/) 참고
* 단, kubeconfig 업데이트는 아래 명령어를 사용

```sh
aws eks update-kubeconfig --region ap-northeast-2 --name network-policy-error
```

# 오류 재현 방법
* 특정 pod(이 예제에서는 nginx) replica를 줄였다 늘렸다를 무한 반복하면, 어느 순간부터 특정 pod에 통신이 안됨
* [스크립트 링크](./manifests/nginx/scale_up_down.sh)
* 참고: https://youtu.be/Qac3r5WjY7Y
