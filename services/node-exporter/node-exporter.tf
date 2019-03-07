variable "networks" {
  type = "list"
}
resource "docker_service" "exporter" {
    name = "exporter-service"

    task_spec {
        container_spec {
            image = "prom/node-exporter"

            command = [
                "/bin/node_exporter"
            ]
            args = [
                "--path.procfs=/host/proc",
                "--path.sysfs=/host/sys"
            ]
            mounts = [
                {
                    target      = "/host/proc"
                    source      = "/proc"
                    type        = "bind"
                    read_only   = true
                },
                {
                    target      = "/host/sys"
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
            ]
        }
        networks     = ["${var.networks}"]
    }
}