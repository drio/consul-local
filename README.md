
# Exploring consul locally

This repo contains the necessary pieces to explore [consul](https://www.hashicorp.com/products/consul) locally.

You can see a video of this process [here](https://www.youtube.com/watch?v=KKJw4tOKiCw).

# Requirements

- go
- consul
- envoy

# How to run it

You are going to need a bunch of terminals running (I hope you use a [terminal multiplexer](https://github.com/tmux/tmux)).

1. `make` will start consul.

2. Start the randomer services (one per terminal):
  ```
  $ rm -f services/randomer/bin/frontend-randomer ; make service/run/frontend
  $ rm -f services/randomer/bin/backend-randomer ; make service/run/backend
  $ make run/proxy/frontend
  $ make run/proxy/backend
  ```

3. Star the prometheus and node_exporter services:
  ```
  $ make service/run/prometheus
  $ make run/proxy/prometheus
  $ make service/run/node-exporter
  $ make run/proxy/node-exporter
  ```

4. `make intentions/allow; make fabio` will start some intentions so certain services can talk to each other.
And then will start fabio that will create http routes based on the services configuration (tag entries).

5. Finally, run `make kv/del` to remove some routes that fabio created and that we don't want (routes to the
proxies).

If you visit now the [consul ui](http://localhost:8500) you should see all the services running healhty.

To make things more interesting I created the following local dns entries (/etc/hosts):

```
127.0.0.1       randomer.local
127.0.0.1       randomer.tufts-dev.edu
127.0.0.1       prometheus.local
127.0.0.1       node-exporter.local
127.0.0.1       fabio.local
```

So now you can explore:

- `http://randomer.local:9999`
- `http://prometheus.local:9090/targets?search=`

You can also deny traffic from the frontend to the backend via the proxy and see how the app fails:

`$ make intentions/deny`

to allow it again:

`$ make intentions/allow`

# Other things to do

We have a [service](https://github.com/fabiolb/fabio/blob/master/demo/server/server.go) (fabio-demo) 
that you can use to dynamically register services into consul.
