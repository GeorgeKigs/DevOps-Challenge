resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags = merge({
    Name = "${var.region}-${var.project}-subnet-group"
    },
    var.tags
  )
}


resource "aws_db_instance" "this" {
  allocated_storage = 10
  db_name           = "jumia_phone_validator"
  engine            = "postgres"
  instance_class    = var.instance_class
  username          = var.username
  password          = var.password
  port              = 5432
  # parameter_group_name   = aws_db_parameter_group.this.name
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids

  multi_az            = false
  skip_final_snapshot = true

  tags = merge({
    Name = "${var.region}-${var.project}-rds"
    },
    var.tags
  )
}