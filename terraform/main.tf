##START_DATA_SOURCE

data "aws_vpc" "default" {
  default = true
}
data "aws_internet_gateway" "default" {
  filter {
    name = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

##END_DATA_SOURCE


resource "aws_subnet" "subnet" {
  vpc_id            = data.aws_vpc.default.id # FROM DATA SOURCE
  cidr_block        = var.subnet_range_ips # FROM VARIABLES
  availability_zone = "us-east-1a"

  tags = {
    name = "Prod Subnet"
  }
}



resource "aws_security_group" "sg" {
   name        = "security_group"
   description = "Allow All inbound traffic"
   vpc_id      = data.aws_vpc.default.id
   ingress {
     description = "Allow all protocols from any port to any port, from any ip"
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
  # ingress {
  #   description = "HTTP"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
   egress {
     description = "Allow all protocols from any port to any port, from any ip"
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }
   tags = {
     Name = " security_group"
   }
 }
resource "aws_network_interface" "server-nic" {
  for_each        = toset(var.instance_ips)
  subnet_id       = aws_subnet.subnet.id
  private_ips     = [each.key]
  security_groups = [aws_security_group.sg.id]
  tags = {
    Name = "NIC-${each.key}"
  }
}
resource "null_resource" "wait_for_eip_association" {
  provisioner "local-exec" {
    command = <<-EOT
      sleep 30  # Wait 30 seconds before associating EIP
    EOT
  }
  depends_on = [aws_instance.server-instances]
}

resource "aws_eip" "server_eips" {
  for_each                  = aws_network_interface.server-nic
  vpc                       = true
  network_interface         = each.value.id
  associate_with_private_ip = each.key
  depends_on                = [data.aws_internet_gateway.default,null_resource.wait_for_eip_association]

  tags = {
    Name = "EIP-${each.key}"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "oussama-key"
  public_key = file("oussama.pub")
}
resource "aws_instance" "server-instances" {
for_each                  = aws_network_interface.server-nic
  ami               = "ami-0866a3c8686eaeeba"
  instance_type     = "t3.medium"
  availability_zone = "us-east-1a"
  key_name          = aws_key_pair.deployer.key_name
  # Root volume configuration
  root_block_device {
    volume_type = "gp3" # EBS volume type: gp2, gp3, io1, io2, st1, sc1
    volume_size = 40    # Size in GiB
  }
  user_data = <<-EOF
                  #!/bin/bash
                  set -euxo pipefail  # Exit on error, show executed commands
                  apt update -y
                  apt upgrade -y
                  apt install -y software-properties-common python3 python3-pip
                  add-apt-repository --yes --update ppa:ansible/ansible || echo "Failed to add Ansible PPA"
                  apt update -y
                  apt install -y ansible || echo "Failed to install Ansible"
                  EOF

  network_interface {
    device_index         = 0
    network_interface_id = each.value.id
  }
    tags = {
    Name = lookup({
      "172.31.96.80" = "MASTER"
      "172.31.96.81" = "WORKER1"
      "172.31.96.82" = "WORKER2"
    }, each.value.private_ip, "unknown-node")
  }
}
