#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "infi-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "terraform-eks-infi-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "infisubnet" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.infi-vpc.id

  tags = map(
    "Name", "terraform-eks-infi-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "eks-ig" {
  vpc_id = aws_vpc.infi-vpc.id

  tags = {
    Name = "terraform-eks-cluster"
  }
}

resource "aws_route_table" "eks-rt" {
  vpc_id = aws_vpc.infi-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-ig.id
  }
}

resource "aws_route_table_association" "eks-rta" {
  count = 2

  subnet_id      = aws_subnet.infisubnet.*.id[count.index]
  route_table_id = aws_route_table.eks-rt.id
}
