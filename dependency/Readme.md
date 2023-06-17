# 개요
* 테라폼 종속성 그래프 예제

# 실행방법
```bash
terraform init
terraform apply
```

# 종속성 그래프 파일 생성
* 그래프 파일은 graphviz뷰어에서 볼 수 있습니다.

```bash
terraform graph > graph.dot
```

![](graph.png)
