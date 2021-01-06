#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EC2 Security Group to allow networking traffic
#  * Data source to fetch latest EKS worker AMI
#  * AutoScaling Launch Configuration to configure worker instances
#  * AutoScaling Group to launch worker instances
#

resource "aws_iam_role" "demo-node" {
  name = "terraform-eks-demo-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.demo-node.name}"
}



resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.demo-node.name}"
}

resource "aws_iam_instance_profile" "demo-node" {
  name = "terraform-eks-demo"
  role = "${aws_iam_role.demo-node.name}"
}

resource "aws_security_group" "demo-node" {
  name        = "terraform-eks-demo-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.demo.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-demo-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "demo-node-ssh" {
  description              = "ssh"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-node.id}"
  to_port                  = 22
  type                     = "ingress"
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "demo-node-ping" {
  description              = "ping"
  from_port                = 8
  protocol                 = "icmp"
  security_group_id        = "${aws_security_group.demo-node.id}"
  to_port                  = 0
  type                     = "ingress"
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "demo-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.demo-node.id}"
  source_security_group_id = "${aws_security_group.demo-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.demo-node.id}"
  source_security_group_id = "${aws_security_group.demo-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-https-ipv4" {
  description              = "Https rule port 443"
  security_group_id        = "${aws_security_group.demo-node.id}"
  from_port                = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-https-ipv6" {
  description              = "Https rule port 443 ipv6"
  security_group_id        = "${aws_security_group.demo-node.id}"
  from_port                = 443
  protocol                 = "tcp"
  ipv6_cidr_blocks              = ["::/0"]
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-dkube-ui" {
  description              = "custom tcp port 32222"
  security_group_id        = "${aws_security_group.demo-node.id}"
  from_port                = 32222
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 32222
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-dkube-ui-ipv6" {
  description              = "custom tcp port 32222 ipv6"
  security_group_id        = "${aws_security_group.demo-node.id}"
  from_port                = 32222
  protocol                 = "tcp"
  ipv6_cidr_blocks              = ["::/0"]
  to_port                  = 32222
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-dkube-installer-ui" {
  description              = "custom tcp port 32222"
  security_group_id        = "${aws_security_group.demo-node.id}"
  from_port                = 32323
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 32323
  type                     = "ingress"
}

resource "aws_security_group_rule" "demo-node-ingress-dkube-installer-ui-ipv6" {
  description              = "custom tcp port 32222 ipv6"
  security_group_id        = "${aws_security_group.demo-node.id}"
  from_port                = 32323
  protocol                 = "tcp"
  ipv6_cidr_blocks              = ["::/0"]
  to_port                  = 32323
  type                     = "ingress"
}

##resource "aws_security_group_rule" "demo-node-ingress-all-traffic" {
##  description              = "All traffic ingree"
##  security_group_id        = "${aws_security_group.demo-node.id}"
##  source_security_group_id = "${aws_security_group.demo-node.id}"
##  from_port                = 0
##  protocol                 = "-1"
##  cidr_blocks              = ["0.0.0.0/0"]
##  to_port                  = 0
##  type                     = "ingress"
##}
##
##resource "aws_security_group_rule" "demo-node-ingress-all-traffic-ipv6" {
##  description              = "All traffic ipv6"
##  security_group_id        = "${aws_security_group.demo-node.id}"
##  source_security_group_id = "${aws_security_group.demo-node.id}"
##  from_port                = 0
##  protocol                 = "-1"
##  ipv6_cidr_blocks              = ["::/0"]
##  to_port                  = 0
##  type                     = "ingress"
##}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.demo.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.demo.endpoint}' --b64-cluster-ca '${aws_eks_cluster.demo.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

# TODO: remove hardcoded image_id like below ami-05b4756ea95a5d5a7
# image_id = "${data.aws_ami.eks-worker.id}" "ami-0e09609942bf2ab59" 

resource "aws_launch_configuration" "demo" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.demo-node.name}"
  image_id                    = "ami-0551b6dc0b4079e1d"
  instance_type               = "m5a.4xlarge"
  name_prefix                 = "terraform-eks-demo"
  key_name                    = "sri-ec2"
  security_groups             = ["${aws_security_group.demo-node.id}"]
  user_data_base64            = "${base64encode(local.demo-node-userdata)}"
 
  root_block_device {
    volume_type = "gp2"
    volume_size = 150
    iops = 300
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demo" {
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.demo.id}"
  max_size             = 1
  min_size             = 1
  name                 = "terraform-eks-demo"
  vpc_zone_identifier  = "${aws_subnet.demo[*].id}"

  tag {
    key                 = "Name"
    value               = "terraform-eks-demo"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
  #provisioner "local-exec" {
  #  command = "bash join-worker.sh"
  #}

  #provisioner "local-exec" {
  #  command = "bash configure.sh"
  #}

  #provisioner "local-exec" {
  #  interpreter = ["/bin/bash", "-c"]
  #  command = "sudo bash dkube-install.sh"
  #}
}
