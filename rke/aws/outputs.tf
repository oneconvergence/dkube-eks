output "instance_id" {
  value = aws_instance.RESOURCE_NAME.id
}

output "instance_user_name" {
  value = "ubuntu"
}

output "instance_elastic_ip" {
  value = aws_eip.RESOURCE_NAME.public_ip
}

output "instance_public_ip" {
  value = aws_instance.RESOURCE_NAME.public_ip
}

output "instance_public_dns" {
  value = aws_instance.RESOURCE_NAME.public_dns
}

output "instance_private_ip" {
  value = aws_instance.RESOURCE_NAME.private_ip
}
