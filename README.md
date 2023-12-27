TUTORIAL:
HOW TO USE TERRAFORM IN MULTI ENVIRONMENTS

In the previous tutorial, we solved one problem by modularising our Terrafrom code to facilitate code reuse.
We can now simply put in different parameters in our terraform.tfvars file.
There is however another problem to be solved

To use this configuration in different environments however, we shall need to have different remote backends or the resources may overwrite one another and may produce unwanted and unexpected results leading to corruption of the statefile.

We can eliminate this problem by using workspaces.
When we do not explicitly create worspaces, terraform creates a default workspace for us.

With Workspaces, we do not need to create different backends for each environment.

In Terraform, a workspace is a feature that enables you to manage multiple instances of the same infrastructure in a single configuration. Workspaces allow you to create separate environments (such as development, staging, production, testing etc.) using the same Terraform configuration files.

Each workspace maintains its own state, which includes information about the resources that Terraform manages.

The backed will create folders for each enviroment and store that environment's statefile in it's respective folder. 

Before we start, in you want to know how we got our infrastructure to this state, please watch the previous video which is PART 1 and come back here to continue. 
Youtube: https://www.youtube.com/watch?v=CpBQTL7JfOU&t=212s
github: https://github.com/deleonab/terraform-refactor-modules-tutorial


### PART 2 STARTS HERE
1. Let's change our backend from a local backend to a remote backend using Amazon S3 and Dynamo DB

## edit provider.tf and add
```
terraform {
  backend "s3" {
    bucket         = "devops-uncut-remote-backend"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-uncut-terraform-locking"
    encrypt        = true
  }
}
```
### The bucket and dynamo db table already exist in our AWS account

### Please watch one of our other videos in the channel to learn how to set up a remote backend using S3 and DynamoDB.

Youtube:  https://www.youtube.com/watch?v=oz-AQmP5AxA&t=3s

2. Let's create 3 different environments
Production, Staging, Development

The difference in the infrastructure for this demonstration will be as follows:
- Production requires 2 instances of type t2.medium
- Staging requires 2 instances of type t2.micro
- Development requires 1 instance of type t2.micro

```
terraform workspace new production
```
```
terraform workspace new staging
```
```
terraform workspace new development
```

### Create a tfvars file for each environment

```
touch production.tfvars staging.tfvars development.tfvars
```
### edit each environments tfvars with the required variable values

### production.tfvars    2 t2.medium instances
 ```
 vpc_cidr = "10.0.0.0/16"

subnet_cidr = "10.0.1.0/24"

ec2_count = 2

ami = "ami-0fc5d935ebf8bc3bc"

instance_type = "t2.medium"
 ```

 ### staging.tfvars     2 t2.micro instances
 ```
 vpc_cidr = "10.0.0.0/16"

subnet_cidr = "10.0.1.0/24"

ec2_count = 2

ami = "ami-0fc5d935ebf8bc3bc"

instance_type = "t2.micro"
 ```

 ### development.tfvars   1 t2.micro instance

 ```
 vpc_cidr = "10.0.0.0/16"

subnet_cidr = "10.0.1.0/24"

ec2_count = 1

ami = "ami-0fc5d935ebf8bc3bc"

instance_type = "t2.micro"
 ```

 ### Let us set up tagging of our instances with the name of the workspace and environment they belong too, This way, we can identify them easily in the console later.

 ### We shall use a locals block for this 
 ### Edit my_ec2/my_ec2.tf

 locals {
  ### Define the workspace name
  workspace_name = terraform.workspace
}
### Add workspace_name to the tag
tags = {
    Name = "${workspace_name}-my_EC2-${count.index}"
  }

  ### my_ec2/my_ec2.tf should now look like this
  ```
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

  ```
  ### Now, each instance will have the environment name appended to -my_EC2-${count.index} where count.index is from 0 ,1....x, depending on the number of instances created.

  ### Now let's create our infrastructure in each environment

### initialise our configuration
```
terraform init
```

### production environment
### change to production workspace and run the apply indicating the corresponding tfvars file using -var-file=filename
  ```
  terraform  workspace select production
  ```
  ```
  terraform apply -var-file=production.tfvars
  ```

### staging environment
### change to staging workspace and run the apply indicating the corresponding tfvars file using -var-file=filename
  ```
  terraform  workspace select staging
  ```
  ```
  terraform apply -var-file=staging.tfvars
  ```
### development environment
### change to development workspace and run the apply indicating the corresponding tfvars file using -var-file=filename
  ```
  terraform  workspace select development
  ```
  ```
  terraform apply -var-file=development.tfvars
  ```