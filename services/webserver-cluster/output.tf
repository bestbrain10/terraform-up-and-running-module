output "alb_dns_name" {
    value = aws_lb.launch_lb.dns_name
    description = "The domain name of the Load balancer"
}

output "asg_name" {
    value = aws_autoscaling_group.launch_asg.name
    description = "The name of the auto scaling group"
}