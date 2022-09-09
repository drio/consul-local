build-bins: clean
	mkdir -p bin && \
	cd backend && \
	go build -o ../bin/backend-randomer ./... && \
	cd ../frontend && \
	go build -o ../bin/frontend-randomer ./...

.PHONY: clean
clean:
	rm -f bin/*
