
# Step 1: Create IAM Role
resource "aws_iam_role" "load_balancer_controller" {
  name               = "load-balancer-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "load_balancer_full_access" {
  name        = "load-balancer-full-access-policy"
  description = "Policy for AWS Load Balancer Controller Full Access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_load_balancer_policy" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_full_access.arn
}

# Step 2: Retrieve EC2 Instances by Subnet ID
data "aws_instances" "instances_by_subnet" {
  filter {
    name   = "subnet-id"
    values = ["subnet-12345678"] # Replace with your subnet ID
  }
}

# Step 3: Attach IAM Role to EC2 Instances
resource "aws_iam_instance_profile" "instance_profile" {
  name = "load-balancer-controller-instance-profile"
  role = aws_iam_role.load_balancer_controller.name
}

resource "aws_instance" "attach_role" {
  for_each = toset(data.aws_instances.instances_by_subnet.ids)

  instance_id            = each.value
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
}

















#DATA SOURCE
data "aws_instances" "example" {
  filter {
    name   = "subnet-id" #Filter by subnet id
    values = ["subnet-06983ead049985fac"] # Replace with your actual subnet ID
  }
}

output "instance_ids" {
  value = data.aws_instances.example.ids
}


output "public_ips" {
  value = data.aws_instances.example.public_ips
}


resource "aws_iam_role" "load_balancer_controller" {
  name = "LoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  description = "Role for AWS Load Balancer Controller"
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller_policy" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerFullAccess" # Or your custom policy ARN
}

resource "aws_iam_instance_profile" "load_balancer_controller" {
  name = "LoadBalancerControllerRole"
  role = aws_iam_role.load_balancer_controller.name
}


# Attach the IAM role to the retrieved instances
resource "aws_ec2_instance_profile_association" "example" {
  for_each   = toset(data.aws_instances.example.ids)
  instance_id  = each.key
  instance_profile = aws_iam_instance_profile.load_balancer_controller.name
}

