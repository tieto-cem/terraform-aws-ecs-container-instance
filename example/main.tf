provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = "${data.aws_vpc.default.id}"
}

#------------------------------------------
# Task definition for testing ECS cluster
#------------------------------------------
resource "aws_ecs_task_definition" "hello_world_task" {
  family                = "tests"
  container_definitions = <<EOF
[
  {
    "name": "hello-world",
    "image": "tutum/hello-world",
    "memoryReservation": 256,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOF
}

#------------------------------------------------------------------
#  ECS cluster itself and ECS service for running Task Definition
#------------------------------------------------------------------

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "test-cluster"
}

module "instance_sg" {
  source      = "github.com/tieto-cem/terraform-aws-sg?ref=v0.1.0"
  name        = "test-cluster-instance-sg"
  vpc_id      = "${data.aws_vpc.default.id}"
  allow_cidrs = {
    "80" = ["0.0.0.0/0"]
  }
}

module "cluster_nano_instances" {
  source                = ".."
  name                  = "test-nano"
  ecs_cluster_name      = "${aws_ecs_cluster.ecs_cluster.name}"
  lc_instance_type      = "t2.nano"
  lc_security_group_ids = ["${module.instance_sg.id}"]
  asg_subnet_ids        = "${data.aws_subnet_ids.default_subnets.ids}"
}

module "cluster_micro_instances" {
  source                = ".."
  name                  = "test-micro"
  ecs_cluster_name      = "${aws_ecs_cluster.ecs_cluster.name}"
  lc_instance_type      = "t2.micro"
  lc_security_group_ids = ["${module.instance_sg.id}"]
  asg_subnet_ids        = "${data.aws_subnet_ids.default_subnets.ids}"
}


resource "aws_ecs_service" "ecs_service" {
  name            = "test-service"
  cluster         = "${aws_ecs_cluster.ecs_cluster.id}"
  task_definition = "${aws_ecs_task_definition.hello_world_task.arn}"
}

#------------------------------------
# Output public IPs of EC2 instances
#------------------------------------

data "aws_instances" "instances" {
  instance_tags {
    Name = "test-*"
  }
  depends_on = ["module.cluster_micro_instances", "module.cluster_nano_instances"]
}

output "instance_test_url" {
  description = "URL for calling container running in ECS cluster"
  value       = <<EOF
tutum/hello-world container responds from following urls: "${join(", ", formatlist("http://%s", data.aws_instances.instances.public_ips))}"

Note that containers might not respond immediately.

EOF
}
