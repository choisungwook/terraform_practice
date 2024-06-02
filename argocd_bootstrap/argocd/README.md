# 개요
* kustomize로 ArgoCD를 설치

# 전제조건
* [제가 만든 EKS 모듈](../../eks/)를 사용했다는 전제로 ArgoCD를 설치합니다.
* ingress를 사용하려면 External DNS가 설치되어 있어야 합니다.

# 설치 방법
## 값 수정

* ingress hosts수정
```bash
$ vi ./pathces/argocd-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
spec:
  ingressClassName: alb
  rules:
  - host: {Route53 hostzone 도메인}
```

## kustomize로 설치

1. argocd namespace 생성

```sh
kubectl create ns argocd
```

2. kusotmize 배포

```bash
kubectl kustomize ./ | kubectl apply -f -
```

# admin 비밀번호 조회
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

# 삭제

```bash
kubectl kustomize ./ | kubectl delete -f -
```
