output "cloudwatch_dashboard_name" {
  value = aws_cloudwatch_dashboard.lab.dashboard_name
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.web.dns_name
}