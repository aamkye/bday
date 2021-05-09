
resource "aws_lb" "main" {
  name               = "alb-main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg.id]
  subnets            = var.public_subnets.*.id

  enable_deletion_protection = false

  tags = {
    Name = "alb_main"
  }
}

resource "aws_alb_target_group" "main" {
  name        = "alb-tg-main"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
   healthy_threshold   = "3"
   interval            = "10"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = var.health_check_path
   unhealthy_threshold = "2"
  }

  tags = {
    Name = "alb_tg_main"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_tls_cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}
