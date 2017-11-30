##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {}
variable "db_username" {}
variable "db_password" {}
##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

##################################################################################
# RESOURCES
##################################################################################
## Security Groups

resource "aws_security_group" "docker_sg" {
  name        = "docker_sq"
  description = "Allow SSH access to docker node"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]

  }
}

resource "aws_security_group" "rds_sg" {
  name= "sg_rds"
  description = "SQL access from docker_sg security group "


ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.docker_sg.id}"]
  }
}


## Launch Configurations

resource "aws_launch_configuration" "docker" {
  name          = "docker-node-lc"
  image_id      = "ami-bb9a6bc2"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.docker_sg.id}"]
  associate_public_ip_address = true
  key_name = "${var.key_name}"
  user_data = "${file('./docker_install.sh')}"

  lifecycle {
    create_before_destroy = true
  }
}

## Auto Scaling Groups

resource "aws_autoscaling_group" "docker" {
  name                 = "docker-node-as"
  launch_configuration = "${aws_launch_configuration.docker-node-lc.name}"
  min_size             = 1
  max_size             = 1

  lifecycle {
    create_before_destroy = true
  }
}

## RDS

resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.6.17"
  instance_class       = "db.t1.micro"
  name                 = "db"
  username             = "${db_username}"
  password             = "${db_password}"
  db_subnet_group_name = "my_database_subnet_group"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
}
