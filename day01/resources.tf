// docker image for dov-bear
resource docker_image dov-bear {
  name = "stackupiss/dov-bear:${var.tag_version}"
  keep_locally = true
}
// docker image for fortune
resource docker_image fortune {
  name = "stackupiss/fortune:v2"
  keep_locally = true
}


// deploy dov-bear
// to define an container parameters
resource docker_container dov-app {
    
    // --name
    name = var.name
    // docker container run image
        image = docker_image.dov-bear.latest
    
    // define ports
    ports {
      internal = 3000
      external = 8080
    }
    env = [
      "INSTANCE_NAME=dov-app",
      "INSTANCE_HASH=abc123"
    ]
}
//deploy fortune
resource docker_container fortune-app {
    // --name
    name = "fortune-app"
    // docker container run image
    image = docker_image.fortune.latest
    // define ports
    ports {
      internal = 3000
      external = 8081
    }
}
data "docker_network" "host" {
  name = "host"
}

output "docker-ip" {
  value = data.docker_network.host
}