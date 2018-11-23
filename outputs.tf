output "asg_id" {
  description = "ASG id"
  value       = "${aws_autoscaling_group.asg.id}"
}

output "asg_name" {
  description = "ASG name"
  value       = "${aws_autoscaling_group.asg.name}"
}

output "lc_id" {
  description = "Launch Configuration id"
  value      = "${aws_launch_configuration.lc.id}"
}
