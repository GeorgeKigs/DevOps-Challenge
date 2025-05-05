data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.imported_vpc_id
  gw_id  = var.create_igw ? aws_internet_gateway.this[0].id : var.imported_igw_id
  nat_id = var.create_nat_gw ? aws_nat_gateway.this[0].id : var.imported_nat_gw_id
}

resource "aws_vpc" "this" {
  count      = var.create_vpc ? 1 : 0
  cidr_block = var.cidr_block

  tags = merge({
    Name = "${var.region}-${var.project}-vpc"
    },
    var.tags
  )
}

# routes and gateways
resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge({
    Name = "${var.region}-${var.project}-igw"
    },
    var.tags
  )
}


# gateway route table
resource "aws_route_table" "gw_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.gw_id
  }

  tags = merge({
    Name = "${var.region}-${var.project}-igw-rt"
    },
    var.tags
  )
}


# availabilty zone subnets
resource "aws_subnet" "private" {
  count = length(var.private_cidr_block)

  vpc_id                  = local.vpc_id
  cidr_block              = var.private_cidr_block[count.index]
  availability_zone       = data.aws_availability_zones.this.names[count.index]
  map_public_ip_on_launch = false

  tags = merge({
    Name = "${var.region}-${var.project}-private-subnet-${count.index + 1}}"
    },
    var.tags
  )
}


resource "aws_subnet" "public" {
  count = length(var.public_cidr_block)

  vpc_id                  = local.vpc_id
  cidr_block              = var.public_cidr_block[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.this.names[count.index]

  tags = merge({
    Name = "${var.region}-${var.project}-public-subnet-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr_block)

  route_table_id = aws_route_table.gw_rt.id
  subnet_id      = element(aws_subnet.public.*.id, count.index)
}

resource "aws_security_group" "this" {
  name        = "${var.region}-main-sg"
  description = "Describes the security group to be used"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "${var.region}-${var.project}-sg"
    },
    var.tags
  )

}

# configuring the nat gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge({
    Name = "${var.region}-${var.project}-eip"
    },
    var.tags
  )
}


resource "aws_nat_gateway" "this" {
  count             = var.create_nat_gw ? 1 : 0
  subnet_id         = aws_subnet.public[0].id
  allocation_id     = aws_eip.nat_eip.id
  connectivity_type = "public"
  tags = merge({
    Name = "${var.region}-${var.project}-nat-gw"
    },
    var.tags
  )
}

# gateway route table
resource "aws_route_table" "nat_rt" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.nat_id
  }

  tags = merge({
    Name = "${var.region}-${var.project}-nat_rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr_block)

  route_table_id = aws_route_table.nat_rt.id
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}


resource "aws_vpc_security_group_egress_rule" "this" {
  from_port         = 0
  to_port           = 0
  ip_protocol       = -1
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.this.id
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_protocol" {
  from_port   = 22
  to_port     = 22
  ip_protocol = "6"
  cidr_ipv4   = "0.0.0.0/0"
  # referenced_security_group_id = aws_security_group.this.id
  security_group_id = aws_security_group.this.id

}

# secuurity group for load balancer
resource "aws_security_group" "load_balancer" {
  name        = "${var.region}-load_balancer-sg"
  description = "Describes the security group to be used"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "${var.region}-load_balancer-sg"
    },
    var.tags
  )

}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_protocol" {
  cidr_ipv4   = var.cidr_block_sg_lb
  from_port   = 0
  to_port     = 80
  ip_protocol = -1
  # referenced_security_group_id = aws_security_group.this.id
  security_group_id = aws_security_group.load_balancer.id

  lifecycle {
    ignore_changes = all
  }
}

# security group for database balancer
resource "aws_security_group" "database" {
  name        = "${var.region}-database-sg"
  description = "Describes the security group to be used"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "${var.region}-database-sg"
    },
    var.tags
  )

}

resource "aws_vpc_security_group_ingress_rule" "database_protocol" {
  cidr_ipv4   = var.cidr_block_sg_db
  from_port   = 0
  to_port     = 0
  ip_protocol = "6"
  # referenced_security_group_id = aws_security_group.this.id
  security_group_id = aws_security_group.database.id

  lifecycle {
    ignore_changes = all
  }
}


# security group for microservice balancer
resource "aws_security_group" "microservice" {
  name        = "${var.region}-micro-sg"
  description = "Describes the security group to be used"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "${var.region}-micro-sg"
    },
    var.tags
  )


}

resource "aws_vpc_security_group_ingress_rule" "microservice_protocol" {
  cidr_ipv4   = var.cidr_block_sg_microservice
  from_port   = 0
  to_port     = 0
  ip_protocol = -1
  # referenced_security_group_id = aws_security_group.this.id
  security_group_id = aws_security_group.this.id

  lifecycle {
    ignore_changes = all
  }
}