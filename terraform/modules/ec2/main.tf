# we do not need this since we have a gateway

# resource "aws_eip" "name" {
#   domain = "vpc"
# }

# resource "aws_eip_association" "name" {
#   instance_id = ""
#   allocation_id = ""
# }

data "aws_ami" "int-ec2-instance" {
  most_recent = true
  owners      = [var.os_details_owner]

  filter {
    name   = "name"
    values = [var.os_details]
  }
}

resource "aws_key_pair" "int-ec2-key-pair" {
  public_key = file(var.key_name)
  key_name   = "public-key"
}

resource "aws_instance" "int-instance" {
  # machine type details
  instance_type = var.instance_type
  count         = var.ec2_count
  tags          = var.tags

  # image used
  ami      = data.aws_ami.int-ec2-instance.id
  key_name = aws_key_pair.int-ec2-key-pair.id

  # Networking
  security_groups = var.security_group
  subnet_id       = var.subnet_id

  # disk size
  root_block_device {
    volume_size           = var.disk_size
    delete_on_termination = true
    encrypted             = true
  }
}