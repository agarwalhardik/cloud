// provider for AWS
provider "aws" {
     region = "ap-south-1"
     profile = "hardikagarwal"
}
// provider for kubernetes
provider "kubernetes" {
  config_context = "minikube"
}
// creating a VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"
  tags = {
    Name = "task_vpc"
  }
}
// creating a Internet Gateway
resource "aws_internet_gateway" "IG" {
depends_on = [
    aws_vpc.vpc,
  ]
  vpc_id = aws_vpc.vpc.id
tags = {
    Name = "task_IG"
  }
}
// creating a Routing Table
resource "aws_route_table" "rt1" {
depends_on = [
    aws_vpc.vpc,
  ]
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }
tags = {
    Name = "RT_IG"
  }
}
// association of Routing Table
resource "aws_route_table_association" "a1" {
depends_on = [
    aws_route_table.rt1,aws_subnet.subnet1
  ]
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}
// creating a subnet in VPC
resource "aws_subnet" "subnet1" {
depends_on = [
    aws_vpc.vpc,
  ]
vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
tags = {
    Name = "subnet1"
  }
}
// creating a subnet in VPC
resource "aws_subnet" "subnet2" {
depends_on = [
    aws_vpc.vpc,
  ]
vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1c"
tags = {
    Name = "subnet2"
  }
}
data "aws_subnet_ids" "sub_ids" {
depends_on = [
          aws_vpc.vpc,
          aws_subnet.subnet1,aws_subnet.subnet2
     ]
  vpc_id = aws_vpc.vpc.id
}
resource "aws_db_subnet_group" "db_subnet_group" {
depends_on = [data.aws_subnet_ids.sub_ids]
  name       = "main"
  subnet_ids = data.aws_subnet_ids.sub_ids.ids
tags = {
    Name = "My DB subnet group"
  }
}
// creating a Security Group for MYSQL
resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "Allows port 3306"
  vpc_id      = aws_vpc.vpc.id
ingress {
    description = "port 3306 for SQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "sg1"
  }
}
// creating a DataBase instance in AWS RDS
resource "aws_db_instance" "mydb" {
depends_on = [aws_db_subnet_group.db_subnet_group,aws_security_group.sg1]
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "hardik"
  password             = "hardikagarwal"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.sg1.id]
  skip_final_snapshot  = true
  publicly_accessible = true
}
// creating a WordPress deployment in Kubernetes
resource "kubernetes_deployment" "wordpress" {
depends_on = [
          aws_db_instance.mydb
     ]
  metadata {
    name = "wordpress"
    
  }
spec {
    replicas = 1
selector {
      match_labels = {
        env = "prod"
        country = "IN"
        app = "wordpress"
      }
    }
template {
      metadata {
        labels = {
          env = "prod"
          country = "IN"
          app = "wordpress"
        }
      }
spec {
        container {
          image = "wordpress:5.1.1-php7.3-apache"
          name  = "wp-con"
}
      }
    }
  }
}
// creating a Service in Kubernetes for Exposing the deployment
resource "kubernetes_service" "wordpress-service"{
     depends_on = [
          kubernetes_deployment.wordpress,
     ]
     metadata{
          name="wordpress"
     }
     spec{
          selector={
               app = "wordpress"
               
          }
     port{
          node_port=31234
          port=80
          target_port=80
     }
     type="NodePort"
     }
}
