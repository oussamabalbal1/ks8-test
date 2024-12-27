variable "subnet_range_ips" {
  description = "Range of IPs that used in the subnet"
  type        = string
  default     = "172.31.96.0/20"
}
variable "instance_ips" {
  description = "List of IP addresses for EC2 instances"
  type        = list(string)
  default     = ["172.31.96.80", "172.31.96.81", "172.31.96.82"] # Example static IPs
}
