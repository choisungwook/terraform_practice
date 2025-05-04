# Managed node group 설정 예

> terraform.tfvars에 설정

* 기본

```hcl
managed_node_groups = {
  "managed-node-group-a" = {
    node_group_name = "managed-node-group-a",
    instance_types  = ["t3.medium"],
    capacity_type   = "ON_DEMAND",
    release_version = "1.32.3-20250501",
    disk_size       = 20,
    desired_size    = 1,
    max_size        = 1,
    min_size        = 1
  }
}
```

* labels과 taint 설정

```hcl
managed_node_groups = {
  "managed-node-group-b" = {
    node_group_name = "managed-node-group-b",
    instance_types  = ["t3.medium"],
    capacity_type   = "ON_DEMAND",
    release_version = "1.32.3-20250501",
    disk_size       = 20,
    desired_size    = 1,
    max_size        = 1,
    min_size        = 1,
    labels         = {
      "node-type" = "managed-node-group-b"
    }
    taints = [
      {
        key    = "node-type"
        value  = "managed-node-group-b"
        effect = "NO_SCHEDULE"
      }
    ]
  }
}
```
