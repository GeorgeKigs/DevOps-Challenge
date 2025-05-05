output "vpc_id" {
  value = local.vpc_id
}
output "internet_gateway_id" {
  value = local.gw_id
}
output "public_subnet_id" {
  value = [for id in aws_subnet.public : id.id]
}
output "private_subnet_id" {
  value = [for id in aws_subnet.private : id.id]
}

# security groups
output "db_security_group_id" {
  value = aws_security_group.database.id
}

output "lb_security_group_id" {
  value = aws_security_group.load_balancer.id
}

output "main_security_group_id" {
  value = aws_security_group.this.id
}

output "micro_security_group_id" {
  value = aws_security_group.microservice.id
}