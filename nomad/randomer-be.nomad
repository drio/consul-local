// vim: set ft=hcl
job "be-randomer" {
  datacenters = ["dc1"]

  group "be-randomer-group" {
    count = 1
    network {
      port "be-randomer-port" {
        to = 7050
      }
    }

		service {
      name = "be-randomer"
      port = "7050"

      check {
        type     = "http"
        path     = "/ping"
        method   = "GET"
        interval = "1s"
        timeout  = "1s"
      }
    }

    task "be-randomer" {
      driver = "raw_exec"

      config {
        command = "/Users/drio/dev/tufts/consul-local/services/randomer/bin/backend-randomer"
        //args    = [""]
      }
    }
  }
}
