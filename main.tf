resource "docker_network" "proxy" {
  name = "proxy"
  driver = "overlay"
}
module "traefik" {
  source = "services/traefik"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  domain = "traefik.monitor.anvibo.com"
  acme_email = "ssl@anvibo.com"
}
module "grafana" {
  source = "services/grafana"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
}
module "prometheus" {
  source = "services/prometheus"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
}
module "exporter" {
  source = "services/node-exporter"
  networks = ["${docker_network.proxy.id}"]
}