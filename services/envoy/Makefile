/usr/local/bin/envoy: envoy
	sudo cp envoy /usr/local/bin/

envoy: func-e
	cp ~/.func-e/versions/1.23.0/bin/envoy .

func-e:
	curl -s -L https://func-e.io/install.sh | bash -s -- -b .;\
	export FUNC_E_PLATFORM=darwin/arm64;\
	./func-e use 1.23.1

clean:
	rm -rf envoy func-e /usr/local/bin/envoy ~/.func-e
