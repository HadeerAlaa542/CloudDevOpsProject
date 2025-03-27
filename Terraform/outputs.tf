output "master_public_ip" {
  value = module.master_server.public_ip
}

output "slave_public_ip" {
  value = module.slave_server.public_ip
}