.PHONY: consul/start consul/down consul/stop consul/info consul/reload \
	fabio \
	intentions intentions/deny intentions/allow \
	service/run/frontend service/run/backend
consul/start:
	@echo "🙋 Remember to run the intentions *after* starting consul"
	@echo "NOTE: We won't load the services in ./consul.d"
	@echo "Press <ENTER> to continue..."
	@read $$FOO
	#consul agent -dev -node airconsul -config-dir=./consul.d
	consul agent -dev -node airconsul

consul/stop:
	consul config delete -kind service-intentions -name frontend-randomer
	consul config delete -kind service-intentions -name backend-randomer
	consul leave

consul/reload:
	consul reload

consul/info:
	@echo "Registered Services"
	@consul catalog services
	@echo "Member list"
	@consul members

nomad/start:
	sudo nomad agent -bind 0.0.0.0 -log-level INFO -dev

kv/fabio/add:
	# echo
	consul kv put 'fabio/config/echo' 'route add echo  echo.local:9999 http://localhost:5050/'
	consul kv put 'fabio/config/echo2' 'route add echo2 localhost:9999/echo http://localhost:5050/'
	# rm proxy entry for fe
	consul kv put 'fabio/config/fe-scar-proxy-rm' 'route del frontend-randomer-sidecar-proxy'
	# randomer fe
	consul kv put 'fabio/config/randomer-fe' 'route add randomer-fe randomer.local:9999 http://localhost:7060/'
	# node-exporter
	consul kv put 'fabio/config/node-exporter' 'route add node-exporter node-exporter.local:9999 http://localhost:9100/'
	# prometheus
	consul kv put 'fabio/config/prometheus' 'route add prometheus prometheus.local:9999 http://localhost:9090/'

kv/fabio/del:
	consul kv delete -recurse 'fabio/config'

kv/list:
	consul kv get -recurse

intentions/allow:
	@for i in `ls intentions/*allow*`;do \
		consul config write $$i;\
	done

intentions/deny:
	@for i in `ls intentions/*deny*`;do \
		consul config write $$i;\
	done

intentions/deny/all:
	consul intention create -deny '*' '*'	

intentions/allow/all:
	consul intention create -allow '*' '*'	



service/run/frontend: services/randomer/bin/frontend-randomer
	BACKEND_URL=http://localhost:7061 services/randomer/bin/frontend-randomer

service/run/backend: services/randomer/bin/backend-randomer
	cd services/randomer/backend; go run *.go

service/run/prometheus:
	cd services/prometheus; prometheus

service/run/node-exporter:
	cd services/node-exporter; node_exporter



run/proxy/frontend:
	consul connect envoy -sidecar-for frontend-randomer -admin-bind localhost:19000

run/proxy/backend:
	consul connect envoy -sidecar-for backend-randomer -admin-bind localhost:19001

run/proxy/node-exporter:
	consul connect envoy -sidecar-for node-exporter -admin-bind localhost:19002

run/proxy/prometheus:
	consul connect envoy -sidecar-for prometheus -admin-bind localhost:19003



services/randomer/bin/frontend-randomer services/randomer/bin/backend-randomer:
	cd services/randomer; make

