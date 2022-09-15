// vim: set ft=hcl
job "node-exporter" {
  datacenters = ["dc1"]

  group "ne-group" {
    count = 1
    network {
      port "node-exporter" {
        to = 9100
      }
    }

		service {
      name = "node-exporter"
      tags = [ "url-prefix-/echo", "node-exporter.local:9999/" ]
      port = "9100"
    }

    task "node-exporter" {
      driver = "raw_exec"

      config {
        command = "/opt/homebrew/bin/node_exporter"
      }
    }
  }
}
