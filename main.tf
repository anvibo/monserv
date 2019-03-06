resource "docker_network" "proxy" {
  name = "proxy"
  driver = "overlay"
}
module "traefik" {
  source = "services/traefik"
  networks = "${list("${docker_network.proxy.id}")}"
}
module "grafana" {
  source = "services/grafana"
  networks = "${list("${docker_network.proxy.id}")}"
  traefik_network = "${docker_network.proxy.name}"
}
module "prometheus" {
  source = "services/prometheus"
  networks = "${list("${docker_network.proxy.id}")}"
  traefik_network = "${docker_network.proxy.name}"
}