resource "docker_network" "proxy" {
  name = "proxy"
  driver = "overlay"
}
module "traefik" {
  source = "anvibo/traefik/docker"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "traefik.mon.anvibo.com"
  acme_email = "ssl@anvibo.com"
  acme_volume_mountpoint = "/storage/hdd1/monserv10_traefik_acme"
}
module "grafana" {
  source = "anvibo/grafana/docker"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "dashboard.mon.anvibo.com"
  vol1_mountpoint = "/storage/hdd1/monserv10_grafana_data"
}
module "prometheus" {
  source = "anvibo/prometheus/docker"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "prometheus.mon.anvibo.com"
  vol1_mountpoint = "/storage/hdd1/monserv10_prometheus_data"
}
module "exporter" {
  source = "anvibo/node-exporter/docker"
  networks = ["${docker_network.proxy.id}"]
}
module "cadvisor" {
  source = "anvibo/cadvisor/docker"
  networks = ["${docker_network.proxy.id}"]
}

module "jenkins" {
  source  = "anvibo/jenkins/docker"
  networks = ["${docker_network.proxy.id}"]
  traefik_network = "${docker_network.proxy.name}"
  url = "prometheus.mon.anvibo.com"
  jenkins_data_mount = "/storage/hdd1/jenkins_data"
}