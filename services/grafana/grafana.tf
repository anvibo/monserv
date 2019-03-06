variable "networks" {
  type = "list"
}

variable "traefik_network" {
}


resource "docker_volume" "grafana_data" {
  name = "grafana_data"
}

resource "docker_service" "grafana" {
    name = "grafana-service"

    task_spec {
        container_spec {
            image = "grafana/grafana"

            labels {
                traefik.frontend.rule = "Host:dashboard.mon.anvibo.com"
                traefik.port = 3000
                traefik.docker.network = "${var.traefik_network.name}"
            }

         

            mounts = [
                {
                    source      = "${docker_volume.grafana_data.name}"
                    target      = "/var/lib/grafana"   
                    type        = "volume"
                    read_only   = false
                },
                
            ]
        }
        networks     = "${var.networks}"
    }
}