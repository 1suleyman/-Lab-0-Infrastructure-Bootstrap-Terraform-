output "public_ip" {
  value       = aws_instance.this.public_ip
  description = "Public IPv4"
}

output "security_group_id" {
  value       = aws_security_group.lab_sg.id
  description = "Security group ID"
}