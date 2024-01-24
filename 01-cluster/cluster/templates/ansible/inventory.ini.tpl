[gateway_servers]
%{ for name, server in gateway_servers ~}
${name}
%{ endfor ~}


