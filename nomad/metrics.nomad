// vim: ft=hcl
job "metrics" {
  datacenters = ["dc1"]

  group "prometheus" {
    count = 1

    network {
      port "prometheusgroupserver" {
        to = 9090
      }
    }

		service {
      name = "prometheus"
      tags = [ "url-prefix-/prometheus", "prometheus.local:9999/"  ]
      port = 9090
    }

    task "prometheus" {
      driver = "raw_exec"

      config {
        command = "/opt/homebrew/bin/prometheus"
				args = [ "--config.file=/Users/drio/dev/tufts/consul-local/services/prometheus/prometheus.yml",
							   "--storage.tsdb.path=/Users/drio/dev/tufts/consul-local/services/prometheus/data" ]
      }
		}
  }

  group "node-exporter" {
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
