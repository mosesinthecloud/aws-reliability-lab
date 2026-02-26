# AWS Reliability Lab

Production-style AWS high-availability stack built with Terraform, Auto Scaling, and observability.

---

## Overview

This project is a hands-on infrastructure lab focused on building a resilient, production-style web stack in AWS using Terraform.

The goal was not just to deploy EC2 instances, but to design and debug a complete system that includes:

- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Launch Templates
- CPU-based auto scaling policies
- Health checks
- Dynamic user-data rendering
- Secure SSH access
- Infrastructure as Code (Terraform)

This lab simulates real-world reliability engineering scenarios, including debugging failed health checks, launch template misconfiguration, package conflicts in Amazon Linux 2023, and resolving ALB 502 errors.

---

## Architecture

The stack consists of:

- VPC with public subnets
- Application Load Balancer
- Target Group with HTTP health checks
- Auto Scaling Group
- Launch Template
- Amazon Linux 2023 EC2 instances
- CPU-based scaling policy
- User-data script that installs Nginx and dynamically renders instance metadata

Each instance renders:

- Instance ID  
- Availability Zone  
- Private IP  
- Render timestamp  

If the Instance ID changes, it confirms that the ASG replaced the node.

---

## Key Technical Decisions

### Infrastructure as Code

All resources are defined using Terraform.

The configuration is structured into logical components:

- Networking
- Security
- Compute
- Autoscaling
- Variables

State is managed locally for lab purposes.

---

### Launch Template + ASG Integration

The Launch Template defines:

- AMI
- Instance type
- Security groups
- SSH key pair
- User data

The ASG references the Launch Template and uses a rolling instance refresh strategy to automatically replace instances when configuration changes.

---

### CPU-Based Auto Scaling

Auto Scaling policies are configured to scale out based on average CPU utilization.

This allows the environment to automatically adjust capacity under load.

---

### Health Checks & Debugging

The ALB performs HTTP health checks against the instances.

During development, I resolved:

- Nginx not starting due to user-data script failures
- Package conflicts between `curl` and `curl-minimal` on Amazon Linux 2023
- Launch template missing SSH key configuration
- Instances failing target group health checks
- 502 Bad Gateway errors from the ALB

The final configuration ensures:

- Nginx installs reliably
- User-data executes without early termination
- Instances register healthy in the target group
- ALB routes traffic successfully

---

## Security

- SSH restricted to my public IP via security group
- Key pair managed via AWS EC2
- No private keys stored in the repository
- `.terraform`, state files, and `.tfvars` excluded via `.gitignore`

---

## Validation

System health is verified by:

- Confirming Nginx responds locally (`curl localhost`)
- Verifying target group health is `healthy`
- Confirming ALB routes traffic successfully
- Observing ASG instance replacement behavior
- SSH access validation

---

## Lessons Learned

This lab reinforced several real-world concepts:

- A failing user-data script can silently break an entire environment.
- Amazon Linux 2023 has package management nuances that must be accounted for.
- Launch Templates must explicitly include SSH key configuration.
- ALB 502 errors almost always trace back to application or health-check issues.
- Instance refresh strategies are critical for configuration changes.

More importantly, debugging infrastructure requires methodical validation at each layer:

1. Instance
2. Service (nginx)
3. Target group
4. Load balancer
5. Auto Scaling behavior

---

## Future Enhancements

- HTTPS listener with ACM certificate
- WAF integration
- CloudWatch dashboards
- Remote Terraform state (S3 + DynamoDB)
- Blue/Green deployment strategy
- CI/CD integration