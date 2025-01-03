# Sleep for a specified duration
resource "time_sleep" "wait" {
  depends_on = [aws_instance.server-instances] # Ensure it waits after instance provisioning
  create_duration = "30s" # Specify wait time (e.g., 20 seconds)
}


output "ec2_public_ips" {
  depends_on = [time_sleep.wait] # Ensure it waits for the sleep resource
  value = [for inst in aws_instance.server-instances : inst.public_ip]
  description = "Public IPs of the EC2 instances"
}

output "ec2_private_ips" {
  value = [for inst in aws_instance.server-instances : inst.private_ip]
  description = "Private IPs of the EC2 instances"
}

output "ec2_ids" {
  value = [for inst in aws_instance.server-instances : inst.id]
  description = "Ids for EC2 instances"
}
output "vpc_id" {
  value = data.aws_vpc.default.id
  description = "Id of the VPC"
}

output "subnet_id" {
  value = aws_subnet.subnet.id
  description = "Id of the subnet"
}

