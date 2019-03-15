variable "networks" {
  type = "list"
}
variable "traefik_network" {
}
variable "url" {
}
variable "consul_data_mountpoint" {
  
}

resource "docker_volume" "consul_data" {
  name = "consul_data"
  driver = "local-persist"
  driver_opts = {
      "mountpoint" = "${var.consul_data_mountpoint}"
  }
}
resource "docker_service" "consul" {
    name = "consul-service"

    task_spec {
        container_spec {
            image = "consul"
            env {
                CONSUL_BIND_INTERFACE = "eth0"
                CONSUL_CLIENT_INTERFACE = "eth0"
            }

            labels {
                traefik.frontend.rule = "Host:${var.url}"
                traefik.port = 8500
                traefik.docker.network = "${var.traefik_network}"
            }

            mounts = [
                {
                    source      = "${docker_volume.consul_data.name}"
                    target      = "/consul/data"   
                    type        = "volume"
                    read_only   = false
                },
                
            ]
        }
        networks     = ["${var.networks}"]
    }
}