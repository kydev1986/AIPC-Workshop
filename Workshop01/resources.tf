# Create a new Web Droplet in the singapore region
resource digitalocean_droplet server {
  image  = var.do_image
  name   = "nginx-server"
  region = var.do_region
  size   = var.do_size
  ssh_keys = [
      data.digitalocean_ssh_key.do-key.fingerprint
  ]
  connection {
    type = "ssh"
    user = "root"
    private_key = file(var.private_key)
    host = self.ipv4_address
  }
  // install nginx
  provisioner "remote-exec" {
    inline = [
      "apt update -y",
      "apt upgrade -y",
      "apt install nginx -y",
      "systemctl start nginx",
      "systemctl enable nginx"
    ]
    
  }
  // copy file to target host
  // create connection object - provisioner
  provisioner "file" {
    source = local_file.nginx-conf.filename
    destination = "/etc/nginx/nginx.conf"
  }
  // signal nginx to reload
  provisioner "remote-exec" {
    inline = [
      "nginx -s reload"
    ]
  }
}


// USING DO public key
data "digitalocean_ssh_key" "do-key" {
  name = "do-key"
}

//for local key
/* resource "digitalocean_ssh_key" "local-key" {
  name = "local-key"
  public_key = file()
} */

data docker_image dov-image {
  name = var.app_image
}

resource "docker_container" "dov-container" {
  count = var.app_count
  name = "dov-${count.index}"
  image = data.docker_image.dov-image.id
  ports {
    internal = 3000
  }
  env = [ "INSTANCE_NAME=dov-${count.index}"]
}

resource "local_file" "nginx-conf" {
  filename = "nginx.conf"
  file_permission = 0644
  content = templatefile("nginx.conf.tpl",{
    docker_host = var.docker_host
    ports = flatten(docker_container.dov-container[*].ports[*].external)
  })
}

//Generate local file
resource "local_file" "at_ip4" {
  filename = "root@${digitalocean_droplet.server.ipv4_address}"
  file_permission = "0644"
  content = "${data.digitalocean_ssh_key.do-key.fingerprint}\n"
}

// droplet info
resource "local_file" "droplet_info" {
  filename = "info.txt"
  content = templatefile("info.txt.tpl",{
      ipv4 = digitalocean_droplet.server.ipv4_address
      fingerprint = data.digitalocean_ssh_key.do-key.fingerprint
  })
  file_permission = "0644"
}


output app-ports {
    value = flatten(docker_container.dov-container[*].ports[*].external)
}
output "do-key-fingerprint" {
    value = data.digitalocean_ssh_key.do-key.fingerprint
}
output ipv4 {
    value = digitalocean_droplet.server.ipv4_address
}
