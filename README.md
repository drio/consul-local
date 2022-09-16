
# Exploring consul and nomad locally

This repo contains the necessary pieces to explore [consul](https://www.hashicorp.com/products/consul) locally.

You can see a video of this process (consul only) [here](https://vimeo.com/manage/videos/748180645).

# Requirements

- go
- consul
- envoy

# How to run it (consul+nomad version)

Before we start, make sure you have some local dns entries in your `/etc/hosts`:

```
127.0.0.1       randomer.local
127.0.0.1       randomer.tufts-dev.edu
127.0.0.1       prometheus.local
127.0.0.1       node-exporter.local
127.0.0.1       fabio.local
127.0.0.1       echo.local
```

Notice I still have to setup proxies to achieve feature parity between the consul version and
ehe consul+nomad version. The bridge network mode is not supported under macOS only Linux.

In this branch we also run nomad to provide orchestration.

1. Start consul: `make consul`

2. Allow all the services to talk to each other: `make intentions/allow/all`

3. Start nomad: `cd nomad; make`. `nomad status` will show no jobs.

4. Let's start fabio via nomad. (from the nomad dir): `nomad job run fabio.nomad`

5. Let's check the logs for the fabio job's main task:

```
$ nomad alloc logs -f -stderr `nomad job status fabio | tail -1 | awk '{print $1}'` server
...
```

You can point your browser to: `http://fabio.local:9998` and you should have access to the
fabio UI.

6. Let's run the echo nomad job (from the nomad dir):

```
$ nomad job run echo.nomad

$ nomad job status
ID    Type     Priority  Status   Submit Date
echo  service  50        running  2022-09-16T08:13:30-04:00

$ consul catalog services
consul
echo
nomad
nomad-client
```

We see our echo service, the consul client and then
the nomad services (client and server).

If you try to access the service via echo.local:9999. It won't work. Until I figure out why fabio
does not read the service tags, we have to create the [url-prefix entries](https://fabiolb.net/quickstart/)
manually.

To do so, run: `cd ../; make kv/fabio/add`. Notice that will add all the necessary prefixes for all the
services. If you are watching the fabio log, you should see the new entries appearing. You can also check the
fabio UI.

7. The `metrics` job. The metrics job has a couple of groups with one task each: prometheus and the node_exporter.
Run: `cd nomad; nomad run job metrics.job`. If you access `http://prometheus.local:9999` you should see the prometheus
UI. Navigate to the targets to confirm that prometheus has access to the node_exporter.

8. And finally we will run the randomer job which is a simple web app with two groups and one task
per group: a frontend and a backend. `nomad run job randomer.nomad`. Try to access the frontend via:
`http://randomer.local:9999`.

# How to run it (plain consul)

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

