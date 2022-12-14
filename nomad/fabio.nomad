// vim: set ft=hcl
job "fabio" {
  datacenters = ["dc1"]
  type        = "system"

  group "fabiogroup" {
    count = 1

    network {
      port "lb" {
        to = 9999
      }
      port "ui" {
        to = 9998
      }
    }

		service {
      name = "fabio"
      tags = [ "urlprefix-fabio.local:9999/" ]
      port = "9999"
    }

    task "server" {
      driver = "raw_exec"

      config {
        command = "/opt/homebrew/bin/fabio"
      }
    }
  }
}
