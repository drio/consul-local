start:
	sudo nomad agent -dev -bind 0.0.0.0 -log-level INFO

status:
	nomad node status
	@echo ""
	nomad server members
	@echo ""
	nomad job status

ui:
	open http://localhost:4646

job/doc/init:
	nomad job init

job/short/init:
	nomad job init -short

job/run/%:
	nomad job run $*.nomad

job/stop/%:
	nomad job stop $*

job/status/%:
	nomad alloc status $*

job/logs/%:
	nomad alloc logs $*

job/plan/%:
	nomad job plan $*.nomad

