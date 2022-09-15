// vim: set ft=hcl
job "be-randomer-proxy" {
  datacenters = ["dc1"]

  group "be-randomer-proxy-group" {
    count = 1

		service {
      name = "be-randomer-proxy"
      port = 19001
      // TODO: check
    }

    task "be-randomer-proxy-envoy" {
      driver = "raw_exec"

      config {
        command = "/opt/homebrew/bin/consul"
        args    = ["connect", "envoy", "-sidecar-for", "be-randomer", "-admin-bind", "19001" ]
      }
    }
  }
}
