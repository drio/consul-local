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

fabio:
	@echo "🙋 Remember to kb/del to remove unwanted routes"
	@echo "Press <ENTER> to continue..."
	@read $$FOO
	fabio

kv/del:
	consul kv put 'fabio/config' 'route del frontend-randomer-sidecar-proxy'

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

