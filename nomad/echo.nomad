// vim: set ft=hcl
job "echo" {
  datacenters = ["dc1"]

  group "echogroup" {
    count = 1
    network {
      port "echogroupserver" {
        to = 5050
      }
    }

		service {
      name = "echo"
      tags = [ "url-prefix-/echo", "urlprefix-echo.local:9999/"  ]
      port = "5050"
    }

    task "server" {
      driver = "raw_exec"

      config {
        command = "/Users/drio/dev/tufts/consul-local/services/http-echo/http-echo"
        args    = ["-listen", "127.0.0.1:5050", "-text", "echo here"]
      }
    }
  }
}
