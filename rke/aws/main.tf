# you'll need to provide credentials in ~/.aws/credentials
# make sure you add the key and secret under the [terraform] profile
provider aws {
  region  = "us-east-1"
  profile = "terraform"
}

resource "aws_vpc" "RESOURCE_NAME" {
  cidr_block           = "87.0.0.0/16"
  instance_tenancy     = "dedicated"
  enable_dns_hostnames = true

  tags {
    Name = "RESOURCE_NAME"
  }
}

# allow our VPC to talk to the public internet
resource "aws_internet_gateway" "RESOURCE_NAME" {
  vpc_id = "${aws_vpc.RESOURCE_NAME.id}"

  tags {
    Name = "RESOURCE_NAME"
  }
}

locals {
  # the deep learning AMI we want is only available in specific AZ's
  avail_zone = "us-east-1c"
}

# define the subnet to put our instance in
resource "aws_subnet" "RESOURCE_NAME" {
  vpc_id                  = "${aws_vpc.RESOURCE_NAME.id}"
  cidr_block              = "${aws_vpc.RESOURCE_NAME.cidr_block}"
  map_public_ip_on_launch = true
  availability_zone       = "${local.avail_zone}"

  tags {
    Name = "RESOURCE_NAME"
  }
}

# this is for the default route table that was created with our VPC
resource "aws_default_route_table" "RESOURCE_NAME" {
  default_route_table_id = "${aws_vpc.RESOURCE_NAME.default_route_table_id}"

  # make sure all outbound traffic goes through the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.RESOURCE_NAME.id}"
  }

  tags {
    Name = "default table"
  }
}

# attach route table to the sbnet
resource "aws_route_table_association" "RESOURCE_NAME" {
  subnet_id      = "${aws_subnet.RESOURCE_NAME.id}"
  route_table_id = "${aws_vpc.RESOURCE_NAME.default_route_table_id}"
}

# permit inbound access to all the ports we need
resource "aws_security_group" "RESOURCE_NAME" {
  name   = "allow_443"
  vpc_id = "${aws_vpc.RESOURCE_NAME.id}"

  # jupyter uses 8888 by default
  ingress {
    from_port   = 443
    to_port     = 443
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

  # just allow everything outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "RESOURCE_NAME"
  }
}

# to permit SSH access
resource "aws_key_pair" "RESOURCE_NAME" {
  key_name   = "RESOURCE_NAME"
  public_key = "${file("${var.public_key_file}")}"
}

# the actual compute instance
resource "aws_instance" "RESOURCE_NAME" {
  # this AMI has python, jupyter, tensorflow, etc preinstalled on Ubuntu!
  ami = "ami-7336d50e"

  # a type with a beefy GPU is required
  instance_type          = "${var.instance_type}"
  availability_zone      = "${local.avail_zone}"
  subnet_id              = "${aws_subnet.RESOURCE_NAME.id}"
  vpc_security_group_ids = ["${aws_security_group.RESOURCE_NAME.id}"]
  key_name               = "RESOURCE_NAME"

  tags {
    Name = "RESOURCE_NAME"
  }
}

# assign a constant IP that we can reach
resource "aws_eip" "RESOURCE_NAME" {
  instance = "${aws_instance.RESOURCE_NAME.id}"
  vpc      = true

  tags {
    Name = "RESOURCE_NAME"
  }
}
