all:
  hosts:
    ${host_name}:
      ansible_ssh_host: ${host_ip}
      ansible_connection: ssh
      ansible_user: root
      ansible_ssh_private_key_file: ${private_key}
      cs_password: ${cs_password}