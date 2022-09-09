package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

const (
	defaultBindAddr   = "0.0.0.0:7060"
	defaultBackendURL = "http://localhost:7050"
	envBindAddr       = "BIND_ADDR"
	envBackendURL     = "BACKEND_URL"
)

func main() {
	// Decide on Gin mode.
	if os.Getenv(gin.EnvGinMode) != gin.DebugMode {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	// https://pkg.go.dev/github.com/gin-gonic/gin#readme-don-t-trust-all-proxies
	if err := r.SetTrustedProxies(nil); err != nil {
		log.Fatal(err.Error())
	}

	// Figure out our bind address.
	bindAddr := defaultBindAddr
	if addr := os.Getenv(envBindAddr); addr != "" {
		bindAddr = addr
	}

	// Figure out what URL to use for the backend service.
	backendURL := defaultBackendURL
	if url := os.Getenv(envBackendURL); url != "" {
		backendURL = strings.TrimSuffix(url, "/")
	}

	// Instantiate an HTTP client with keep alives disabled
	// so intentions take effect immediately.
	t := http.DefaultTransport.(*http.Transport).Clone()
	t.DisableKeepAlives = true
	httpClient := &http.Client{Transport: t}

	// Setup the routes.
	setupRoutes(r, httpClient, backendURL)

	// Start the server.
	logf("Starting server listen_addr=%q", bindAddr)
	if err := r.Run(bindAddr); err != nil && err != http.ErrServerClosed {
		logf("Error: %s", err)
	}
}

// logf is a helper function that operates like logf but always
// adds a newline.
func logf(format string, v ...interface{}) {
	format = strings.TrimSuffix(format, "\n")
	log.Printf(format+"\n", v...)
}
