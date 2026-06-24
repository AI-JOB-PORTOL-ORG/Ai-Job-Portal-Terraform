data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnet_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, index)
  ]

  private_app_subnet_cidrs = length(var.private_app_subnet_cidrs) > 0 ? var.private_app_subnet_cidrs : [
    for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, index + var.az_count)
  ]

  private_db_subnet_cidrs = length(var.private_db_subnet_cidrs) > 0 ? var.private_db_subnet_cidrs : [
    for index in range(var.az_count) : cidrsubnet(var.vpc_cidr, 4, index + (var.az_count * 2))
  ]

  eks_cluster_tags = var.eks_cluster_name == null ? {} : {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    local.eks_cluster_tags,
    {
      Name                     = "${var.name_prefix}-public-${local.azs[count.index]}"
      Tier                     = "public"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "private_app" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_app_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    local.eks_cluster_tags,
    {
      Name                              = "${var.name_prefix}-private-app-${local.azs[count.index]}"
      Tier                              = "private-app"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_subnet" "private_db" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_db_subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-db-${local.azs[count.index]}"
    Tier = "private-db"
  })
}

resource "aws_eip" "nat" {
  count = var.single_nat_gateway ? 1 : var.az_count

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  count = var.single_nat_gateway ? 1 : var.az_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
    Tier = "public"
  })
}

resource "aws_route_table" "private_app" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-app-rt-${local.azs[count.index]}"
    Tier = "private-app"
  })
}

resource "aws_route_table" "private_db" {
  count = var.az_count

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-db-rt-${local.azs[count.index]}"
    Tier = "private-db"
  })
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count = var.az_count

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app[count.index].id
}

resource "aws_route_table_association" "private_db" {
  count = var.az_count

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db[count.index].id
}
