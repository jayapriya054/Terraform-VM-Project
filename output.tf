output "Machine1_public_ip" {
  value = aws_instance.Machine1.public_ip
}

output "Machine2_public_ip" {
  value = aws_instance.Machine2.public_ip
}