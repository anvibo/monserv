resource "docker_network" "proxy" {
  name = "proxy"
  driver = "overlay"
}
module "traefik" {
  source = "services/traefik"
  networks = ["${split(",", join(",", docker_network.proxy.id))}"]
}
module "grafana" {
  source = "services/grafana"
  networks = ["${split(",", join(",", docker_network.proxy.id))}"]
  traefik_network = "${docker_network.proxy.name}"
}
module "prometheus" {
  source = "services/prometheus"
  networks = ["${split(",", join(",", docker_network.proxy.id))}"]
  traefik_network = "${docker_network.proxy.name}"
}