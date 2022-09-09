service {
  name = "node-exporter"
  port = 9100
  tags = [ ]

  connect {
    sidecar_service {
      port = 22002
    }
  }

 check {
    id       = "node-exporter-check"
    http     = "http://localhost:9100/metrics"
    method   = "GET"
    interval = "1s"
    timeout  = "1s"
  }
}
