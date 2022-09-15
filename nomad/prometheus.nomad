// vim: set ft=hcl
job "prometheus" {
  datacenters = ["dc1"]

  group "prometheusgroup" {
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

    task "prometheus-bin" {
      driver = "raw_exec"

      config {
        command = "/opt/homebrew/bin/prometheus"
				args = [ "--config.file=/Users/drio/dev/tufts/consul-local/services/prometheus/prometheus.yml",
							   "--storage.tsdb.path=/Users/drio/dev/tufts/consul-local/services/prometheus/data" ]
      }
		}


  }
}
