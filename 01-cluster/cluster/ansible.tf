## the roles

locals {
  server_role   = "server"
  gateway_role  = "gateway"
}

## render the run script

resource "local_file" "run_playbook" {
  content = templatefile("templates/ansible/run-ansible.sh.tpl", {
      inventory_file = "inventory.ini"
    })
  filename = "local/ansible/run-ansible.sh"
  file_permission = "0755"
}


## render the playbook

resource "local_file" "playbook" {
  content = templatefile("templates/ansible/playbook.yml.tpl", {
      server_role   = local.server_role
      gateway_role  = local.gateway_role
    })
  filename = "local/ansible/playbook.yml"
  file_permission = "0640"
}


## render the inventory file

resource "local_file" "inventory" {
  content = templatefile("templates/ansible/inventory.ini.tpl", {
    gateway_servers = local.gateway_servers
  })
  filename = "local/ansible/inventory.ini"
  file_permission = "0640"
}


## the roles

resource "template_dir" "server" {
  source_dir      = "templates/ansible-roles/${local.server_role}"
  destination_dir = "local/ansible/roles/${local.server_role}"

  vars = {}
}

resource "template_dir" "gateway" {
  source_dir      = "templates/ansible-roles/${local.gateway_role}"
  destination_dir = "local/ansible/roles/${local.gateway_role}"

  vars = {}
}

## the hostvars

resource "local_file" "gateway_hostvars" {
  for_each = aws_instance.gateway
  
  content = templatefile("templates/ansible/host_vars/server.yml.tpl", {
    server_name = local.zone_ids[each.key]
    public_ip   = each.value.public_ip
    private_ip  = each.value.private_ip
    private_cidr_blocks = [local.gateway_cidr_blocks[each.value.availability_zone], local.private_cidr_blocks[each.value.availability_zone]]
  })

  filename        = "local/ansible/host_vars/${local.zone_ids[each.key]}.yml"
  file_permission = "0640"
}

