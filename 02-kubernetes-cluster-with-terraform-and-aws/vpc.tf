resource "aws_vpc" "new-vpc" {
  cidr_block = "10.0.0.0/16" //Aqui, teremos o CIDR block para termos os 65536 ips disponíveis para a nossa VPC
  tags = {
    Name = "fullcycle-vpc"
  }
}

data "aws_availability_zones" "available" {} //Estamos obtendo uma lista com todas as zonas de disponibilidade disponíveis para a região que estamos.
output "az" {
  value = "${data.aws_availability_zones.available.names}"
}


resource "aws_subnet" "new-subnet-1" {
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.new-vpc.id
  cidr_block = "10.0.0.0/24" //Isso foi tirado do IP Calculator
  tags = {
    Name = "fullcycle-subnet-1"
  }
}

resource "aws_subnet" "new-subnet-2" {
  availability_zone = "us-east-1b"
  vpc_id = aws_vpc.new-vpc.id
  cidr_block = "10.0.1.0/24" //Isso foi tirado do IP Calculator
  tags = {
    Name = "fullcycle-subnet-2"
  }
}