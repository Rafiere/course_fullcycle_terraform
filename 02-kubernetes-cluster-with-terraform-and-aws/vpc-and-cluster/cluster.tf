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

/* Estamos configurando o Cloud Watch para o Cluster. */
resource "aws_cloudwatch_log_group" "log" {
  name = "/aws/eks/${var.prefix}-${var.cluster_name}/cluster"
  retention_in_days = var.retention_days //Essa é a quantidade de dias que o CloudWatch vai armazenar os logs.
}

/* Abaixo, estamos criando um cluster no EKS. */

resource "aws_eks_cluster" "cluster" {
  name     = "${var.prefix}-${var.cluster_name}"
  role_arn = aws_iam_role.cluster.arn //O cluster poderá executar todas as policies que a role permite.
  enabled_cluster_log_types = ["api", "audit"] //Sâo os tipos de logs que o cluster vai gerar.

  vpc_config {
    subnet_ids = aws_subnet.subnets[*].id //Estamos pegando todos os subnets que foram criados e colocando dentro do cluster.
    security_group_ids = [aws_security_group.sg.id] //Estamos pegando o security group que foi criado e colocando dentro do cluster.
  }

  depends_on = [
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy
  ]
}