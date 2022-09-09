service {
  name = "frontend-randomer"
  port = 7060
  tags = [
    "urlprefix-randomer.local:9999/"
  ]

  connect {
    sidecar_service {
      port = 21001
      proxy {
        upstreams = [
          {
            destination_name = "backend-randomer"
            local_bind_port  = 7061
          }
        ]
      }
    }
  }

 check {
    id       = "frontend-randomer-check"
    http     = "http://localhost:7060/ping"
    method   = "GET"
    interval = "1s"
    timeout  = "1s"
  }
}
