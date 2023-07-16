terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }

  required_version = ">= 1.4"
}

resource "local_file" "first" {
  content  = "dependency"
  filename = "first.txt"
}

resource "local_file" "second" {
  content  = local_file.first.content
  filename = "second.txt"
}

resource "local_file" "third" {
  content  = "not dependency"
  filename = "third.txt"
}