module "my_ec2_module" {
  source = "./my_ec2"
  ec2_count = var.ec2_count
  instance_type = var.instance_type
  instance_subnet_id = module.my_vpc_module.public_subnet_id
  ami = var.ami
}

module "my_vpc_module" {
  source = "./my_vpc"
  vpc_cidr = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  
}