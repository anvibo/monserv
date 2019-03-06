resource "docker_network" "proxy" {
  name = "proxy"
  driver = "overlay"
}
module "traefik" {
  source = "services/traefik"
  networks = ["${docker_network.proxy.id}"]
}
module "grafana" {
  source = "services/grafana"
  networks = ["${docker_network.proxy.id}"]
}
module "prometheus" {
  source = "services/prometheus"
  networks = ["${docker_network.proxy.id}"]
}