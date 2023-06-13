resource "local_file" "demo" {
  content  = "hi. how are you?"
  filename = "helloworld.txt"
}