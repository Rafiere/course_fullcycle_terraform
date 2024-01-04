/*
   O "resource" é o bloco.
   O "local" é o provider
   O "file" é o tipo do provider
   O "exemplo" é o nome que estamos dando.
*/
resource "local_file" "exemplo" {
  filename = "exemplo.txt"
  content = "Este é um exemplo de arquivo 2"
}