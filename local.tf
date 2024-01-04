/*
   O "resource" é o bloco.
   O "local" é o provider
   O "file" é o tipo do provider
   O "exemplo" é o nome que estamos dando.
*/
resource "local_file" "exemplo" {
  filename = "exemplo2.txt"
  content = var.conteudo
}

variable "conteudo" {
  type = string
  default = "Hello World!"
}

output "id-do-arquivo" {
  value = resource.local_file.exemplo.id
}

output "conteudo" {
  value = resource.local_file.exemplo.content
}

output "chicken-egg" {
  value = sort(["🐔", "🥚"])
}