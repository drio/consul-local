job "fabio" {
  datacenters = ["dc1"]

  group "fabiogroup" {
    count = 1
    network {
      port "fabioport" {
        to = 9999
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
