resource "aws_key_pair" "int-ec2-key-pair" {
  
  public_key = file(var.key_name)
  key_name   = "public-key"
}