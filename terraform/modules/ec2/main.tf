resource "aws_instance" "app" {
  count         = 2
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.security_group_id]

  tags = {
    Name = count.index == 0 ? "Master" : "Slave"
  }
}

