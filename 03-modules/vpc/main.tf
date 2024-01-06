resource "aws_vpc" "new-vpc" {
  cidr_block = "10.0.0.0/16" //Aqui, teremos o CIDR block para termos os 65536 ips disponíveis para a nossa VPC
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

data "aws_availability_zones" "available" {} //Estamos obtendo uma lista com todas as zonas de disponibilidade disponíveis para a região que estamos.
output "az" {
  value = data.aws_availability_zones.available.names
}

resource "aws_subnet" "subnets" {
  count = 2
  availability_zone = data.aws_availability_zones.available.names[count.index] //Pegaremos o índice 0 e 1 do array de zonas de disponibilidade, ou seja, as zonas "a" e "b".
  vpc_id = aws_vpc.new-vpc.id
  cidr_block = "10.0.${count.index}.0/24" //Aqui, estamos usando o count.index para que cada subnet tenha um cidr_block diferente, ou seja, a primeira subnet terá o cidr_block
  map_public_ip_on_launch = true //Todo recurso que entrar dentro da subnet terá um ip público de forma automática.
  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "new-igw" { //Com o "internet gateway", todas as subnets que estiverem associadas a ele, terão acesso à internet.
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "new-rtb" { //Queremos criar a route table inserir o "igw" dentro da Route Table.
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block = "0.0.0.0/0" //Estamos dizendo que qualquer tráfego que não seja para a nossa VPC, será direcionado para o internet gateway.
    gateway_id = aws_internet_gateway.new-igw.id //Estamos inserindo o internet gateway criado nessa route table.
  }
  tags = {
    Name = "${var.prefix}-rtb"
  }
}

resource "aws_route_table_association" "new-rtb-association" { //Estamos associando a nossa route table com as subnets 1 e 2, ou seja, criando um vínculo entre as subnets 1 e 2 e a route table, para que as subnets 1 e 2 tenham acesso à internet, provida pelo internet gateway que está na route table.
  count = 2
  subnet_id = aws_subnet.subnets.*.id[count.index] //Estamos pegando o id das subnets 1 e 2, que estão dentro do array de subnets, e associando com a route table. O asterisco é para que o terraform troque o count.index por 0 e 1, ou seja, o id da subnet 1 e 2.
  route_table_id = aws_route_table.new-rtb.id
}