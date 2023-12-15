output "server_ip" {
  value = aws_instance.ubuntu_server[0].public_ip
}
