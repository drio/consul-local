// vim: set ft=hcl
job "fe-randomer" {
  datacenters = ["dc1"]

  group "fe-randomer-group" {
    count = 1
    network {
      port "fe-randomer-port" {
        to = 7060
      }
    }

		service {
      name = "fe-randomer"
      port = "7050"

      check {
        type     = "http"
        path     = "/ping"
        method   = "GET"
        interval = "1s"
        timeout  = "1s"
      }
    }

    task "fe-randomer" {
      driver = "raw_exec"

      config {
        command = "/Users/drio/dev/tufts/consul-local/services/randomer/bin/frontend-randomer"
        //args    = [""]
      }
    }
  }
}
