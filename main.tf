resource "docker_network" "proxy" {
  name = "proxy"
  driver = "overlay"
}
module "traefik" {
  source = "services/traefik"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "traefik.mon.anvibo.com"
  acme_email = "ssl@anvibo.com"
  acme_volume_mountpoint = "/storage/hdd1/monserv10_traefik_acme"
}
module "grafana" {
  source = "services/grafana"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "dashboard.mon.anvibo.com"
  vol1_mountpoint = "/storage/hdd1/monserv10_grafana_data"
}
module "prometheus" {
  source = "services/prometheus"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "prometheus.mon.anvibo.com"
  vol1_mountpoint = "/storage/hdd1/monserv10_prometheus_data"
}
module "exporter" {
  source = "services/node-exporter"
  networks = ["${docker_network.proxy.id}"]
}