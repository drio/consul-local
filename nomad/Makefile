start:
	sudo nomad agent -bind 0.0.0.0 -log-level INFO -dev driver.raw_exec=1

status:
	nomad node status
	@echo ""
	nomad server members
	@echo ""
	nomad job status

ui:
	open http://localhost:4646

job/doc/init/%:
	nomad job init $*.nomad

job/short/init/%:
	nomad job init -short $*.nomad

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

