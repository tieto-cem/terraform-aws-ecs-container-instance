output "asg_id" {
  description = "ASG id"
  value       = "${aws_autoscaling_group.asg.id}"
}

output "lc_id" {
  description = "Launch Configuration id"
  value      = "${aws_launch_configuration.lc.id}"
}
