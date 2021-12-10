resource digitalocean_droplet server {
  image  = var.do_image
  name   = "server"
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
//Generate local file
resource "local_file" "at_ip4" {
  filename = "root@${digitalocean_droplet.server.ipv4_address}"
  file_permission = "0644"
  content = "${data.digitalocean_ssh_key.do-key.fingerprint}\n"
}

resource "local_file" "inventory-yaml" {
  filename = "ansible/inventory.yaml"
  file_permission = "0644"
  content = templatefile("setup/inventory.yaml.tpl",{
    host_name = digitalocean_droplet.server.name
    host_ip = digitalocean_droplet.server.ipv4_address
    private_key = "${var.private_key}"
    public_key_fred = "${var.public_key_fred}"
  })
}

