provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source             = "../../terraform-aws-vpc"  #FIXME
  name_prefix        = "test"
  azs                = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_cidr           = "10.0.0.0/16"
  enable_nat_gateway = true
}

resource "aws_ecs_cluster" "test_cluster" {
  name = "test-cluster"
}

resource "aws_security_group" "test_cluster_instance_sg" {
  name   = "test-cluster-instance-sg"
  vpc_id = "${module.vpc.id}"

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "test_cluster_nano_instances" {
  source             = ".."
  ecs_cluster_name   = "${aws_ecs_cluster.test_cluster.name}"
  name               = "test-nano"
  instance_type      = "t2.nano"
  subnet_ids         = "${module.vpc.private_subnet_ids}"
  security_group_ids = ["${aws_security_group.test_cluster_instance_sg.id}"]
}

module "test_cluster_micro_instances" {
  source             = ".."
  ecs_cluster_name   = "${aws_ecs_cluster.test_cluster.name}"
  name               = "test-micro"
  instance_type      = "t2.micro"
  subnet_ids         = "${module.vpc.private_subnet_ids}"
  security_group_ids = ["${aws_security_group.test_cluster_instance_sg.id}"]
}