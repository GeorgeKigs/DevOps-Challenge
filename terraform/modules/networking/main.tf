data "aws_availability_zones" "this" {
  state = "available"
}

locals {
  vpc_id = var.create_vpc ? aws_vpc.this[0].id : var.imported_vpc_id
  gw_id  = var.create_igw ? aws_internet_gateway.this[0].id : var.imported_igw_id
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

# resource "aws_internet_gateway_attachment" "this" {
#   count = var.create_igw || var.create_vpc ? 1 : 0

#   vpc_id              = local.vpc_id
#   internet_gateway_id = local.gw_id
# }



# resource "aws_eip" "this" {
#   tags = merge({
#     Name = "${var.region}-${var.project}-NAT-eip"
#     },
#     var.tags
#   )
# }

# resource "aws_nat_gateway" "this" {
#   count             = var.create_nat_gw ? 1 : 0
#   allocation_id     = aws_eip.this.id
#   subnet_id         = element(aws_subnet.public.*.id, 0)
#   connectivity_type = "public"
#   tags = merge({
#     Name = "${var.region}-${var.project}-nat-gw"
#     },
#     var.tags
#   )
# }

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

# nat route table
# resource "aws_route_table" "nat_rt" {
#   vpc_id = local.vpc_id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.this[0].id
#   }
#   tags = merge({
#     Name = "${var.region}-${var.project}-nat-rt"
#     },
#     var.tags
#   )
# }

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

# resource "aws_route_table_association" "private" {
#   count = length(var.private_cidr_block)

#   route_table_id = aws_route_table.nat_rt.id
#   subnet_id      = element(aws_subnet.private.*.id, count.index)
# }

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
  name        = "${var.region}-${var.project}-sg"
  description = "Describes the security group to be used"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "${var.region}-${var.project}-sg"
    },
    var.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "this" {
  from_port         = 0
  to_port           = 0
  ip_protocol       = "TCP"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.this.id
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  from_port                    = 0
  to_port                      = 0
  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.this.id
  security_group_id            = aws_security_group.this.id
}