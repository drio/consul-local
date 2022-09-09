package main

import (
	"log"
	"math/rand"
	"net/http"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
)

const (
	defaultBindAddr = "0.0.0.0:7050"
	envBindAddr     = "BIND_ADDR"
)

func main() {
	// Figure out our bind address.
	bindAddr := defaultBindAddr
	if addr := os.Getenv(envBindAddr); addr != "" {
		bindAddr = addr
	}

	r := gin.Default()
	// https://pkg.go.dev/github.com/gin-gonic/gin#readme-don-t-trust-all-proxies
	if err := r.SetTrustedProxies(nil); err != nil {
		log.Fatal(err.Error())
	}

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})

	r.GET("/random", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"random": randSeq(10),
		})
	})

	r.Run(bindAddr)
}

var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func logf(format string, v ...interface{}) {
	format = strings.TrimSuffix(format, "\n")
	log.Printf(format+"\n", v...)
}
