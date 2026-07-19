output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.ec2_instance.arn
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = var.assign_eip ? aws_eip.ec2_eip[0].public_ip : aws_instance.ec2_instance.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.ec2_instance.private_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ec2_instance.public_dns
}

output "private_dns" {
  description = "Private DNS name of the EC2 instance"
  value       = aws_instance.ec2_instance.private_dns
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2_security_group.id
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_security_group.id
}

output "eip_public_ip" {
  description = "Elastic IP address (if assigned)"
  value       = var.assign_eip ? aws_eip.ec2_eip[0].public_ip : null
}

output "eip_allocation_id" {
  description = "Elastic IP allocation ID (if assigned)"
  value       = var.assign_eip ? aws_eip.ec2_eip[0].id : null
}

output "endpoint" {
  description = "Endpoint URL (for services like Grafana)"
  value       = var.assign_eip ? "http://${aws_eip.ec2_eip[0].public_ip}:3000" : "http://${aws_instance.ec2_instance.private_ip}:3000"
}
