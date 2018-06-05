resource "aws_alb" "main" {
  internal        = "false"
  subnets         = ["${module.vpc.public_subnets}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "arn:aws:iam::708564602958:server-certificate/ssltest"
  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "main" {
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = "${module.vpc.vpc_id}"
  target_type = "ip"
  health_check {
    interval                = 30              
    port                    = "traffic-port"
    protocol                = "HTTP"
    path                    = "/users"
    timeout                 = 10             
    healthy_threshold       = 5               
    unhealthy_threshold     = 5              
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "blog-blog-alb-sg"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "blog_url" {
  value = "http://${aws_alb.main.dns_name}"
}

