package main

import (
	"embed"
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"io/fs"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

//go:embed templates/*
var templatesFS embed.FS

//go:embed static/*
var staticFS embed.FS

type BackendResp struct {
	Random string `json:"random"`
}

type Resp struct {
	Error  string `json:"error,omitempty"`
	Random string `json:"random"`
}

func setupRoutes(r *gin.Engine, httpClient *http.Client, backendURL string) {
	if gin.Mode() == gin.DebugMode {
		r.LoadHTMLGlob("templates/*")
	} else {
		LoadHTMLFromEmbedFS(r, templatesFS, "templates/*")
	}
	fsys, err := fs.Sub(staticFS, "static")
	if err != nil {
		panic(fmt.Sprintf("Unable to load static files: %s", err))
	}
	r.StaticFS("static", http.FS(fsys))

	// The UI.
	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.tmpl", nil)
	})

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status": "pong",
		})
	})

	// TODO
	r.GET("/random", func(c *gin.Context) {
		// Create backend request.
		req, err := http.NewRequestWithContext(
			c.Request.Context(), "GET",
			fmt.Sprintf("%s/random", backendURL), nil)

		if err != nil {
			c.JSON(503, gin.H{
				"metadata": map[string]interface{}{},
				"error":    fmt.Sprintf("Unable to construct request: %s", err),
			})
			return
		}

		// Propagate query params from request.
		queryParams := req.URL.Query()
		for k, v := range c.Request.URL.Query() {
			queryParams.Set(k, v[0])
		}
		req.URL.RawQuery = queryParams.Encode()

		// Make the request.
		resp, err := httpClient.Do(req)

		// backendErrResponse is a helper func for returning an error due to
		// not getting a proper response from backend.
		backendErrResponse := func(err error) {
			log.Printf("Error calling backend: %s\n", err)
			c.JSON(200, Resp{
				Error: err.Error(),
			})
		}

		// Check if the request succeeded.
		if err != nil {
			backendErrResponse(fmt.Errorf("unable to call backend: %w", err))
			return
		}

		// Read the response body.
		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			backendErrResponse(fmt.Errorf("unable to read backend response body: %w", err))
			return
		}

		// Handle unexpected non-JSON response.
		contentType := resp.Header.Get("Content-Type")
		if !strings.Contains(contentType, "application/json") {
			backendErrResponse(fmt.Errorf("received status code %d from backend: %q", resp.StatusCode, string(body)))
			return
		}

		// Unmarshall response.
		var backendResp BackendResp
		err = json.Unmarshal(body, &backendResp)
		if err != nil {
			backendErrResponse(fmt.Errorf("json unmarshalling response body: %s", err))
			return
		}

		// Handle JSON response that was not a 200.
		if resp.StatusCode != 200 {
			c.JSON(200, Resp{
				Error: fmt.Sprintf("received status code %d from backend", resp.StatusCode),
			})
			return
		}

		// Return successfully.
		c.JSON(200, Resp{
			Random: backendResp.Random,
		})
	})
}

func roundDuration(d time.Duration) time.Duration {
	if d > 1*time.Millisecond {
		return d.Round(1 * time.Millisecond)
	}
	return d.Round(1 * time.Microsecond)
}

// LoadHTMLFromEmbedFS makes it possible to use go:embed with Gin's templating
// system.
func LoadHTMLFromEmbedFS(engine *gin.Engine, embedFS embed.FS, pattern string) {
	tmpl := template.Must(template.ParseFS(embedFS, pattern))
	engine.SetHTMLTemplate(tmpl)
}
