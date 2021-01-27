# you'll need to provide credentials in ~/.aws/credentials
# make sure you add the key and secret under the [default] profile
provider aws {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "RESOURCE_NAME" {
  name                 = "RESOURCE_NAME"
  cidr_block           = "87.0.0.0/16"
  instance_tenancy     = "dedicated"
  enable_dns_hostnames = true
}

# allow our VPC to talk to the public internet
resource "aws_internet_gateway" "RESOURCE_NAME" {
  name   = "RESOURCE_NAME"
  vpc_id = aws_vpc.RESOURCE_NAME.id
}

locals {
  avail_zone = "us-east-1d"
}

# define the subnet to put our instance in
resource "aws_subnet" "RESOURCE_NAME" {
  name                    = "RESOURCE_NAME"
  vpc_id                  = aws_vpc.RESOURCE_NAME.id
  cidr_block              = aws_vpc.RESOURCE_NAME.cidr_block
  map_public_ip_on_launch = true
  availability_zone       = local.avail_zone
}

# this is for the default route table that was created with our VPC
resource "aws_default_route_table" "RESOURCE_NAME" {
  name                   = "RESOURCE_NAME"
  default_route_table_id = aws_vpc.RESOURCE_NAME.default_route_table_id

  # make sure all outbound traffic goes through the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.RESOURCE_NAME.id
  }
}

# attach route table to the sbnet
resource "aws_route_table_association" "RESOURCE_NAME" {
  name           = "RESOURCE_NAME"
  subnet_id      = aws_subnet.RESOURCE_NAME.id
  route_table_id = aws_vpc.RESOURCE_NAME.default_route_table_id
}

# permit inbound access to all the ports we need
resource "aws_security_group" "RESOURCE_NAME" {
  name   = "RESOURCE_NAME"
  vpc_id = aws_vpc.RESOURCE_NAME.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH uses 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 32222
    to_port     = 32222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 32323
    to_port     = 32323
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250-10252
    to_port     = 10250-10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379-2380
    to_port     = 2379-2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # just allow everything outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# to permit SSH access
resource "aws_key_pair" "RESOURCE_NAME" {
  key_name   = "RESOURCE_NAME"
  public_key = file(var.public_key_file)
}

data "template_file" "user_data" {
  template = file("startup.yaml")
}

# the actual compute instance
resource "aws_instance" "RESOURCE_NAME" {
  name                   = "RESOURCE_NAME"
  ami                    = "ami-0074ee617a234808d"
  instance_type          = var.instance_type
  availability_zone      = local.avail_zone
  subnet_id              = aws_subnet.RESOURCE_NAME.id
  vpc_security_group_ids = [aws_security_group.RESOURCE_NAME.id]
  key_name               = "RESOURCE_NAME"
  user_data              = data.template_file.user_data.rendered
}

resource "aws_volume_attachment" "RESOURCE_NAME" {
  name        = "RESOURCE_NAME"
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.RESOURCE_NAME.id
  instance_id = aws_instance.RESOURCE_NAME.id
}

# a volume to persist our model after training
resource "aws_ebs_volume" "RESOURCE_NAME" {
  name              = "RESOURCE_NAME"
  availability_zone = local.avail_zone
  size              = "80"
}

# assign a constant IP that we can reach
resource "aws_eip" "RESOURCE_NAME" {
  name     = "RESOURCE_NAME"
  instance = aws_instance.RESOURCE_NAME.id
  vpc      = true
}
