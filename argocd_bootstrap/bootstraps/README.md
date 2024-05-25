# 개요
* EKS구축 후 초기 설치하는 ArgoCD bootstrap

# Bootstrap ArgoCD Application 목록
* [root applicationset](./root-applicationset.yaml)은 가장 먼저 실행되야 하는 ArgoCD applicatino모음(예: ALB controller, ExternalDNS)
* [child applicationset](./child-applicationset.yaml)은 root application실행 이후 생성되는 ArgoCD application모음

# 참고자료
* External DNS Controller helm charts: https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns
