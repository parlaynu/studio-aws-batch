---

# configure the gateways with vpn connections and dnsmasq for the site

- hosts: gateway_servers
  become: yes
  gather_facts: yes
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"
  tasks:
  - import_role:
      name: ${server_role}
  - import_role:
      name: ${gateway_role}


