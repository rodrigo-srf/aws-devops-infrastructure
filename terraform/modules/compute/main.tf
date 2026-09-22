resource "aws_security_group" "web" {
  name_prefix = "${var.project_name}-web-"
  description = "HTTP access for the portfolio container"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }

  egress {
    description = "Outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name      = "${var.project_name}-web-sg"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role" "instance" {
  name_prefix = "${var.project_name}-ec2-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ecr_pull" {
  name = "ecr-pull"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = var.ecr_repository_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "${var.project_name}-"
  role        = aws_iam_role.instance.name
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    dnf update -y
    dnf install -y docker
    systemctl enable --now docker

    REGISTRY="$(echo '${var.container_image}' | cut -d/ -f1)"
    aws ecr get-login-password --region '${var.aws_region}' | docker login --username AWS --password-stdin "$REGISTRY"

    for attempt in $(seq 1 10); do
      if docker pull '${var.container_image}'; then
        docker rm -f devops-app || true
        docker run -d --restart unless-stopped --name devops-app -p 80:8080 '${var.container_image}'
        exit 0
      fi
      sleep 15
    done

    exit 1
  EOT

  tags = {
    Name      = "${var.project_name}-app"
    ManagedBy = "Terraform"
  }
}
