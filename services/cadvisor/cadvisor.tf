variable "networks" {
  type = "list"
}
resource "docker_service" "cadvisor" {
    name = "cadvisor-service"

    task_spec {
        container_spec {
            image = "google/cadvisor"
            hostname = "{{.Node.Hostname}}"
        
            mounts = [
                {
                    target      = "/var/run"
                    source      = "/var/run"
                    type        = "bind"
                    read_only   = false
                },
                {
                    target      = "/sys"
                    source      = "/sys"
                    type        = "bind"
                    read_only   = true
                },
                {
                    target      = "/rootfs"
                    source      = "/"
                    type        = "bind"
                    read_only   = true
                },
                {
                    target      = "/var/lib/docker/"
                    source      = "/var/lib/docker/"
                    type        = "bind"
                    read_only   = true
                },
            ]
        }
        networks     = ["${var.networks}"]
    }
}