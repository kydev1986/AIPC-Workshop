//nginx server
resource digitalocean_droplet droplet {
  image  = data.digitalocean_image.code-server.id
  name   = var.do_name
  region = var.do_region
  size   = var.do_size
  ssh_keys = [
      data.digitalocean_ssh_key.do-key.fingerprint
  ]
}
// USING DO public key
data "digitalocean_ssh_key" "do-key" {
  name = "do-key"
}

data digitalocean_image code-server {
    name = "code-server"
}

resource "local_file" "inventory-yaml" {
  filename = "inventory.yaml"
  file_permission = "0644"
  content = templatefile("inventory.yaml.tpl",{
    host_name = digitalocean_droplet.droplet.name
    host_ip = digitalocean_droplet.droplet.ipv4_address
    private_key = "${var.private_key}"
    cs_password = var.cs_password
  })
}

output ipv4 {
    value = digitalocean_droplet.droplet.ipv4_address
}