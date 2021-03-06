provider "aws" {
  region = "eu-central-1"
  version = "~> 3.12.0"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = data.aws_vpc.default.id
}

locals {
    http_port = 80
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips = ["0.0.0.0/0"] 
}

resource "aws_security_group" "instance_sg" {
    name = "${var.cluster_name}-sg"

    ingress {
        from_port = local.http_port
        to_port = local.http_port
        protocol = local.tcp_protocol
        cidr_blocks = local.all_ips
    }

    egress {
        from_port = local.any_port
        to_port = local.any_port
        protocol = local.any_protocol
        cidr_blocks = local.all_ips
    }
}

data "template_file" "user_data" {
    template = file("${path.module}/user-data.sh")

    vars = {
        server_port = local.http_port
    }
}

resource "aws_launch_configuration" "launch_config" {
    image_id = "ami-00a205cb8e06c3c4e"
    instance_type = var.instance_type
    security_groups = [aws_security_group.instance_sg.id]

    user_data = data.template_file.user_data.rendered

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "launch_asg" {
    launch_configuration = aws_launch_configuration.launch_config.name
    vpc_zone_identifier = data.aws_subnet_ids.default.ids

    min_size = var.min_size
    max_size = var.max_size

    target_group_arns = [aws_lb_target_group.asg_lb_tg.arn]
    health_check_type = "ELB"


    tag {
        key = "Name"
        value = var.cluster_name
        propagate_at_launch = true
    }
}

resource "aws_lb" "launch_lb" {
    name = "${var.cluster_name}-alb"
    load_balancer_type = "application"
    subnets = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.instance_sg.id]
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.launch_lb.arn
    port = local.http_port
    protocol = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "404: Page not found"
            status_code = 404
        }
    }
}

resource "aws_lb_target_group" "asg_lb_tg" {
    name = var.cluster_name
    port = local.http_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn = aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
            values = ["*"]
        }
    }

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg_lb_tg.arn
    }
}