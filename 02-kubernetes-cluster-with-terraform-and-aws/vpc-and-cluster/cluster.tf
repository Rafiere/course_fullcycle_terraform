/* Vamos criar um security group e dar as permissões que ele necessita. */

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.new-vpc.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-sg"
  }
}