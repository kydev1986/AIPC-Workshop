variable do_token {
  type      = string
  sensitive = true
}
variable do_image {
  type    = string
  default = "ubuntu-20-04-x64"
}

variable do_size {
  type    = string
  default = "s-1vcpu-2gb"
}

variable do_region {
  type    = string
  default = "sgp1"
}

// builders
source "digitalocean" "code-server" {
  api_token     = var.do_token
  image         = var.do_image
  region        = var.do_region
  size          = var.do_size
  ssh_username  = "root"
  snapshot_name = "code-server"

}

build {
  sources = ["source.digitalocean.code-server"]
  provisioner ansible {
    playbook_file = "./playbook.yaml"
  }
}