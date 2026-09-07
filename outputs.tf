output "alb_dns_name" {
  description = "Public DNS name of ALB"
  value       = aws_lb.main.dns_name
}