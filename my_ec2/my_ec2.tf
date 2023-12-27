locals {
  # Define the workspace name
  workspace_name = terraform.workspace
}

resource "aws_instance" "my_instance" {
  count = var.ec2_count
  ami           = var.ami
  instance_type = var.instance_type
subnet_id = var.instance_subnet_id
  tags = {
    Name = "${local.workspace_name}-my_EC2-${count.index}"
  }
}
