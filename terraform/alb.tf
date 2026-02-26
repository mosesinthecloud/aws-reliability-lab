resource "aws_lb" "web" {
  name               = "aws-rel-lab-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = [aws_subnet.public.id, aws_subnet.public2.id]
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "web" {
  name     = "aws-rel-lab-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}