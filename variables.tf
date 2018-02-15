variable "name" {
  description = "Name prefix to use in AWS resource names"
}

variable "ecs_cluster_name" {
  description = "Name of a ECS cluster where container instance are registered into"
}

#-----------------------
# Launch Configuration settings
#-----------------------

variable "lc_ecs_optimized_ami_id" {
  description = <<EOF
    ECS optimized ami id used to run container instances.
    Latest ECS optimized AMIs can be found from here https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
EOF
  default     = ""
}

variable "lc_instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "lc_key_pair_name" {
  description = "The EC2 key pair name that should be used for the instance. Instance cannot be connected using SSH if key pair name is not given."
  default     = ""
}

variable "lc_security_group_ids" {
  description = "List of security group IDs protecting container instances"
  type        = "list"
}

variable "lc_associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  default     = false
}

variable "lc_userdata" {
  description = "The user data to provide when launching the instance. Default user data enables container metadata, SSM agent and installs CloudWatch Logs agent."
  default = ""
}


#-------------------
#  ASG settings
#-------------------

variable "asg_min_size" {
  description = "Minimum size of container instances"
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of container instances"
  default     = 2
}

variable "asg_desired_size" {
  description = "Desired size of container instances"
  default     = 1
}

variable "asg_subnet_ids" {
  type        = "list"
  description = "A list of subnet IDs to launch container instances in"
}

variable "asg_default_cooldown" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default     = 300
}