output "ec2_id" {
  value = [for id in aws_instance.int-instance: id.id]
}

output "ec2_ip" {
  value = [for ip in aws_instance.int-instance: ip.private_ip]
}