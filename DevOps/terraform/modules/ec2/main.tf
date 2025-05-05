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


resource "aws_instance" "int-instance" {
  # machine type details
  count = var.ec2_count 
  instance_type = var.instance_type
  ami           = data.aws_ami.int-ec2-instance.id # image used
  key_name      = var.key_name

  # Networking
  security_groups = var.security_group
  subnet_id       = var.subnet_id
  private_ip = var.private_ip[count.index]
  # disk 
  root_block_device {
    volume_size           = var.disk_size
    delete_on_termination = true
    encrypted             = true
  }
  tags = merge({
    Name = "${var.region}-${var.project}-rds" },
  var.tags)

  lifecycle {
    ignore_changes = [ security_groups ]
  }
}