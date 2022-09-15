// vim: set ft=hcl
job "randomer" {
  datacenters = ["dc1"]

  group "frontend" {
    count = 1

    network {
      port "fe-randomer-port" {
        to = 7050
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

    task "frontend" {
      driver = "raw_exec"

      config {
        command = "/Users/drio/dev/tufts/consul-local/services/randomer/bin/frontend-randomer"
      }
    }
  }

  group "backend" {
    count = 1

    network {
      port "port" {
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

    task "backend" {
      driver = "raw_exec"

      config {
        command = "/Users/drio/dev/tufts/consul-local/services/randomer/bin/backend-randomer"
      }
    }
  }
}
