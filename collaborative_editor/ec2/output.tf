output "public-ip-1" {
  value = aws_instance.Instance1.public_ip
}

output "public-ip-2" {
  value = aws_instance.Instance2.public_ip
}