## ssh setup

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.project_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "ssh_key_file" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "local/pki/${var.project_name}"
  file_permission = "0600"
}

resource "local_file" "ssh_config" {
  content = templatefile("templates/ssh.cfg.tpl", {
    ssh_key_file      = local_file.ssh_key_file.filename
    gateway_servers   = local.gateway_servers
  })
  filename        = "local/ssh.cfg"
  file_permission = "0640"
}
