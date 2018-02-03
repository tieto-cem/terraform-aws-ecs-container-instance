AWS ECS Container Instance Terraform module
===========================================

Terraform module which creates and registers cluster instances into specified ECS cluster.

Features
--------
* [AWS System Manager integration](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ec2-run-command.html) 
* [CloudWatch Logs integration](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_cloudwatch_logs.html)
* [Container metadata enabled](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-metadata.html)
* Register container instance to specified cluster

Usage
-----

```hcl

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "test-cluster"
}

module "cluster_instances" {
  source                = ".."
  name_prefix           = "test"
  ecs_cluster_name      = "${aws_ecs_cluster.ecs_cluster.name}"
  lc_instance_type      = "t2.nano"
  lc_security_group_ids = ["sg-12345678"]
  asg_subnet_ids        = ["subnet-12345678", "subnet-23456789"]
}
```

Resources
---------

This module creates following AWS resources:

| Name                                        | Type                 | 
|---------------------------------------------|----------------------|
|${var.name_prefix}-container-instance-role   | IAM Role             | 
|${var.name_prefix}-cloudwatch-logs-policy    | IAM Policy           | 
|${var.name_prefix}-profile                   | EC2 Instance Profile |
|${var.name_prefix}-container-instance-lc-    | Launch configuration |
|${var.name_prefix}-container-instance-asg-   | ASG                  |

Example
-------

* [Simple example](https://github.com/timotapanainen/terraform-aws-ecs-container-instance/tree/master/example)