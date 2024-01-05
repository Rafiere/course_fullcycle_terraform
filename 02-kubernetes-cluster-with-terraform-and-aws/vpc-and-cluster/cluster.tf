/* Vamos criar um security group e dar as permissões que ele necessita. */

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.new-vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-sg"
  }
}

/* Vamos criar as roles e policies */

/* Vamos criar uma policy específica para termos acesso ao "EKS". O <<POLICY serve como
um bloco de EOF, por exemplo. */
resource "aws_iam_role" "cluster" {
  name               = "${var.prefix}-${var.cluster_name}-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
    "Action": "sts:AssumeRole"
    }
  ]
}
  POLICY
}

/* Estamos criando um relacionamento entre uma policy e uma role. */
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController" /* Essa policy é necessária para o EKS e é a que será atachada a role. */
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" /* Essa policy é necessária para o EKS e é a que será atachada a role. */
  role       = aws_iam_role.cluster.name
}