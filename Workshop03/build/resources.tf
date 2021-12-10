resource digitalocean_droplet code-server {
  image  = var.do_image
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

resource "local_file" "inventory-yaml" {
  filename = "setup/inventory.yaml"
  file_permission = "0644"
  content = templatefile("setup/inventory.yaml.tpl",{
    host_name = digitalocean_droplet.code-server.name
    host_ip = digitalocean_droplet.code-server.ipv4_address
    private_key = "${var.private_key}"
  })
}

output ipv4 {
    value = digitalocean_droplet.code-server.ipv4_address
}