variable "networks" {
  type = "list"
}
variable "traefik_network" {
}
resource "docker_volume" "prometheus_data" {
  name = "prometheus_data"
}
data "local_file" "prometheus-yml" {
    filename = "${path.module}/prometheus.yml"
}
resource "docker_config" "prometheus-yml" {
  name = "prometheus-yml-${replace(timestamp(),":", ".")}"
  data = "${base64encode(data.local_file.prometheus-yml.content)}"

  lifecycle {
    ignore_changes = ["name"]
    create_before_destroy = true
  }
}
resource "docker_service" "prometheus" {
    name = "prometheus-service"

    task_spec {
        container_spec {
            image = "prom/prometheus"

            labels {
                traefik.frontend.rule = "Host:prometheus.mon.anvibo.com"
                traefik.port = 9090
                traefik.docker.network = "${var.traefik_network}"
            }

            configs = [
                {
                    config_id   = "${docker_config.prometheus-yml.id}"
                    config_name = "${docker_config.prometheus-yml.name}"
                    file_name = "/etc/prometheus/prometheus.yml"
                },
            ]

            mounts = [
                {
                    target      = "/var/run/docker.sock"
                    source      = "/var/run/docker.sock"
                    type        = "bind"
                    read_only   = true
                },
                {
                    source      = "${docker_volume.prometheus_data.name}"
                    target      = "/prometheus"   
                    type        = "volume"
                    read_only   = false
                },
                
            ]
        }
        networks     = ["${var.networks}"]
    }
}