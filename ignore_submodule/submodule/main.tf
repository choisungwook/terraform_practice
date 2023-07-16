terraform {
  required_providers {
    # reference: https://registry.terraform.io/providers/hashicorp/local/2.4.0
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }

  required_version = ">= 1.4"
}

# reference: https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file.html
resource "local_file" "demo" {
  content  = "hi. how are you?"
  filename = "helloworld.txt"
}