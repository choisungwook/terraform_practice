# 개요
* 테라폼 EKS in-place 업그레이드 연습
* 1.27 -> 1.29 버전으로 업그레이드

# 테라폼 설치
* [EKS 설치 문서](../eks/) 참고
* 단, kubeconfig 업데이트는 아래 명령어를 사용

```sh
aws eks update-kubeconfig --region ap-northeast-2 --name upgrade-example
```

# 업그레이드 전 준비
* karpenter를 배포하고 karpenter로 노드 생성
