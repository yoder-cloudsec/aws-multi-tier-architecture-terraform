resource "aws_iam_role" "ec2_ssm" {
  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm-managed" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2-ssm" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm.name
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2*-x86_64"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private-1a.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-ssm.name

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ec2-user/web
              echo "<h1>Response from Instance A (private_1a)</h1>" > /home/ec2-user/web/index.html
              cd /home/ec2-user/web
              nohup python3 -m http.server 80 &
              EOF

  tags = {
    Name = "app-instance"
  }
}

resource "aws_instance" "app-b" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private-1b.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile = aws_iam_instance_profile.ec2-ssm.name

   user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ec2-user/web
              echo "<h1>Response from Instance B (private_1b)</h1>" > /home/ec2-user/web/index.html
              cd /home/ec2-user/web
              nohup python3 -m http.server 80 &
              EOF              

  tags = {
    Name = "app-tier-instance-b"
  }
}