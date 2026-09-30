data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "app" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "developer-service-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.42.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "developer-service-public"
  }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "developer-service-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "developer-service-public"
  }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.app.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
  name        = "developer-service"
  description = "Allow lab API access from one client IP"
  vpc_id      = aws_vpc.app.id

  ingress {
    description = "API access from lab client"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_client_cidr]
  }

  egress {
    description = "HTTPS for ECR CloudWatch and telemetry"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "developer-service"
  }
}