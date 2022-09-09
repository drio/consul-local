service {
  name = "prometheus"
  port = 9090
  tags = [ ]

  connect {
    sidecar_service {
      port = 21002
      proxy {
        upstreams = [
          {
            destination_name = "node-exporter"
            local_bind_port  = 9101
          }
        ]
      }
    }
  }

 check {
    id       = "prometheus-check"
    http     = "http://localhost:9090/-/healthy"
    method   = "GET"
    interval = "1s"
    timeout  = "1s"
  }
}
