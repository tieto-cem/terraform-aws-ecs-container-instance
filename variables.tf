
variable "ecs_cluster_name" {
  description = "Name of a ECS cluster where container instance are registered into. ECS cluster will be created if cluster with specified name is not found."
}

variable "ecs_optimized_ami_id" {
  description = <<EOF
    ECS optimized ami id used to run container instances.
    Latest ECS optimized AMIs can be found from here https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
EOF
  default = ""
}

variable "name" {
  description = <<EOF
    AWS resource name are prefixed with this name.
    This module names created AWS resources as follows:
    - $${name}-role
    - $${name}-profile
    - $${name}-lc-
    - $${name}-asg
EOF
}

variable "instance_type" {
  default = "t2.micro"
  description = "EC2 instance type."
}

variable "key_pair_name" {
  description = "The EC2 key pair name that should be used for the instance. Instance cannot be connected using SSH if key pair name is not given."
  default = ""
}

variable "security_group_ids" {
  type = "list"
  description = "List of security group IDs protecting container instances"
}

variable "associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  default = false
}

variable "min_size" {
  description = "Minimum size of autoscaling group"
  default = 1
}

variable "max_size" {
  description = "Maximum size of autoscaling group"
  default = 2
}

variable "desired_size" {
  description = "Desired size of autoscaling group"
  default = 1
}

variable "subnet_ids" {
  type = "list"
  description = "A list of subnet IDs to launch resources in"
}