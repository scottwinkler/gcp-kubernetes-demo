package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

func setupRouter() *gin.Engine {
	r := gin.Default()

	// Get hardcoded mesage
	r.GET("/helloworld", func(c *gin.Context) {
		message := "Automate all the things!"
		timestamp := time.Now().Unix()
		c.JSON(http.StatusOK, gin.H{"message": message, "timestamp": timestamp})
	})
	return r
}

func main() {
	r := setupRouter()
	// Listen and Server in 0.0.0.0:8080
	r.Run(":8080")
}
