resource "aws_instance" "this" {
  ami           = "ami-084568db4383264d4" # Ubuntu 24.04 AMI (us-east-1)
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.key_name
  tags = {
    Name = var.instance_name
  }
}