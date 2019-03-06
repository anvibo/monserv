module "traefik" {
  source = "services/traefik"
}
module "grafana" {
  source = "services/grafana"
}
module "prometheus" {
  source = "services/prometheus"
}