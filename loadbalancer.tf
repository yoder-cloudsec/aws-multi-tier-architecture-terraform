resource "aws_lb" "main" {
  name               = "cloud-eng-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public-1a.id, aws_subnet.public-1b.id]

  tags = {
    Name = "cloud-eng-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "app-tier-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "app-tier-tg"
  }
}

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app-b" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id = aws_instance.app-b.id
  port = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}