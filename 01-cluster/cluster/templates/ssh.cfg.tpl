
# gateway servers
%{ for name, server in gateway_servers ~}
Host ${name}
  Hostname ${server.public_ip}
%{ endfor ~}

%{ for name, server in gateway_servers ~}
Host ${name}-spot
  User ec2-user
  Hostname aa.bb.cc.dd
  ProxyJump ${name}
%{ endfor ~}

Host *
  User ubuntu
  IdentityFile ${ssh_key_file}
  IdentitiesOnly yes

