resource "docker_service" "exporter" {
    name = "exporter-service"

    task_spec {
        container_spec {
            image = "prom/node-exporter"

            command = [
                "--path.procfs=/host/proc",
                "--path.sysfs=/host/sys",
                "^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)"
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
        networks     = ["${docker_network.proxy.id}"]
    }
}