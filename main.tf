
#---------------------------------------
# IAM role for ECS container instances
#---------------------------------------

resource "aws_iam_role" "ecs_container_instance_role" {
  name               = "${var.name}-container-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TrustEC2",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# AM policy to allow container instances to use the CloudWatch Logs API
resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name   = "${var.name}-cloudwatch-logs-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_logs_policy_attachment" {
  role       = "${aws_iam_role.ecs_container_instance_role.id}"
  policy_arn = "${aws_iam_policy.ecs_cloudwatch_logs_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "ecs_managed_ec2_policy_attachment" {
  role       = "${aws_iam_role.ecs_container_instance_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


#-------------------------
#  EC2 instance profile
#-------------------------

resource "aws_iam_instance_profile" "ecs_container_instance_profile" {
  name = "${var.name}-profile"
  role = "${aws_iam_role.ecs_container_instance_role.id}"
}


#-------------------------
# EC2 instance userdata
#-------------------------

data "template_file" "userdata" {
  template = "${file("${path.module}/userdata.tpl")}"

  vars {
    cluster_name = "${var.ecs_cluster_name}"
  }
}


#----------------------------------------------------------------------
#  Featch latest ECS optimized ami details if ami id is not specified
#----------------------------------------------------------------------

data "aws_ami" "ecs_ami" {
  count       = "${var.ecs_optimized_ami_id == "" ? 1 : 0}"
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}


#----------------------------
#  Launch configuration
#----------------------------

resource "aws_launch_configuration" "ecs_container_instance_lc" {
  name_prefix                 = "${var.name}-container-instance-lc-"
  # using splat syntax to fix eager evaluation of data reference
  image_id                    = "${var.ecs_optimized_ami_id == "" ? join("", data.aws_ami.ecs_ami.*.id) : var.ecs_optimized_ami_id}"
  instance_type               = "${var.instance_type}"
  security_groups             = ["${var.security_group_ids}"]
  key_name                    = "${var.key_pair_name}"
  user_data                   = "${data.template_file.userdata.rendered}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  enable_monitoring           = true

  iam_instance_profile        = "${aws_iam_instance_profile.ecs_container_instance_profile.id}"

  lifecycle {
    create_before_destroy = true
  }
}


#------------------
#   ASG
#------------------
resource "aws_autoscaling_group" "ecs_container_instance_asg" {
  name                 = "${var.name}-container-instance-asg-${aws_launch_configuration.ecs_container_instance_lc.name}"
  launch_configuration = "${aws_launch_configuration.ecs_container_instance_lc.name}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_size}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  health_check_type    = "EC2"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-container-instance-asg"
    propagate_at_launch = "true"
  }
}

