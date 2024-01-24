---
server_name: ${server_name}

public_ip: ${public_ip}
private_ip: ${private_ip}

private_cidr_blocks:
%{for cidr_block in private_cidr_blocks ~}
- ${cidr_block}
%{ endfor ~}

