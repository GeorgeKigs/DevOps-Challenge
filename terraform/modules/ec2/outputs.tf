output "ec2_id" {
  value = aws_instance.int-instance[0].id
}