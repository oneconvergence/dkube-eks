#
# EFS Resources
#  * EFS
#


resource "aws_efs_file_system" "demo" {
  creation_token = "demo"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"

  tags = {
    Name = "demo"
  }
}

resource "aws_efs_mount_target" "demo" {
  count = 2

  file_system_id  = "${aws_efs_file_system.demo.id}"
  subnet_id = "${aws_subnet.demo.*.id[count.index]}"
  security_groups = ["${aws_security_group.demo-node.id}"]
}

resource "aws_efs_access_point" "demo" {
  file_system_id = "${aws_efs_file_system.demo.id}"
}
