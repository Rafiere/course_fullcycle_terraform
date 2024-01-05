resource "aws_iam_role" "node" {
  name = "${var.prefix}-${var.cluster_name}-role-node"

  //A policy abaixo é do "ec2" porque estamos falando da máquina que vamos subir.
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
    "Action": "sts:AssumeRole"
    }
  ]
}
  POLICY
}

//Essa policy acessará como um "worker", ou seja, um "node" que vai ser executado no cluster.
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

//O CNI é o que permite a comunicação entre os nodes, assim, estamos permitindo que a máquina trabalhe com o CNI.
resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

//Se eu subir as imagens Docker para um container da Amazon, essas máquinas deverão ter a permissão para acessar o container registry e obter as imagens.
resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}


/* Abaixo, temos o código que criará o primeiro nó do cluster. */
resource "aws_eks_node_group" "node-1" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-1"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.subnets[*].id

  scaling_config { //Aqui temos as configurações sobre como todas as máquinas que estarão nesse nó escalarão.
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = ["t2.micro"]

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly
  ]
}