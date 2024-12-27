output "ec2_public_ips" {
  value = [for inst in aws_instance.server-instances : inst.private_ip]
  description = "Public IPs of the EC2 instances"
}
