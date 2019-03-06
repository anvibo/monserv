data "local_file" "telegraf-conf" {
    filename = "telegraf.conf"
}
resource "docker_config" "telegraf-conf" {
  name = "telegraf-conf-${replace(timestamp(),":", ".")}"
  data = "${base64encode(data.local_file.telegraf-conf.content)}"

  lifecycle {
    ignore_changes = ["name"]
    create_before_destroy = true
  }
}
resource "docker_service" "telegraf" {
    name = "telegraf-service"

    task_spec {
        container_spec {
            image = "telegraf"

            env {
                HOST_PROC = "/host/proc"
            }

            configs = [
                {
                    config_id   = "${docker_config.telegraf-conf.id}"
                    config_name = "${docker_config.telegraf-conf.name}"
                    file_name = "/etc/telegraf/telegraf.conf"
                },
            ]

             mounts = [
                {
                    target      = "/host/proc"
                    source      = "/proc"
                    type        = "bind"
                    read_only   = true
                },
            ]
        }
        networks     = ["${docker_network.proxy.id}"]
    }
}