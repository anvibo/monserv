resource "docker_network" "proxy" {
  name = "proxy"
  driver = "overlay"
}
module "traefik" {
  source = "services/traefik"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "traefik.monitor.anvibo.com"
  acme_email = "ssl@anvibo.com"
  acme_volume_mountpoint = "/storage/hdd1/monserv10_traefik_acme"
}
module "grafana" {
  source = "services/grafana"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "dashboard.monitor.anvibo.com"
}
module "prometheus" {
  source = "services/prometheus"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "prometheus.monitor.anvibo.com"
}
module "exporter" {
  source = "services/node-exporter"
  networks = ["${docker_network.proxy.id}"]
}

module "consul" {
  source = "services/consul"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "consul.monitor.anvibo.com"
  consul_data_mountpoint = "/storage/gcs1/monserv10_consul_data"
}