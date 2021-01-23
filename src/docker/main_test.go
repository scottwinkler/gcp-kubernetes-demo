package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/buger/jsonparser"
	"github.com/stretchr/testify/assert"
)

func TestHelloworldRoute(t *testing.T) {
	router := setupRouter()

	w := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/helloworld", nil)
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	data := w.Body.Bytes()

	//test hardcoded message
	message, err := jsonparser.GetString(data, "message")
	if err != nil {
		t.Errorf("unable to get object attribute: %v", err)
	}
	assert.Equal(t, "Automate all the things!", message)

	//verify that timestamp is a number and within last 30 seconds
	timestamp, err := jsonparser.GetInt(data, "timestamp")
	if err != nil {
		t.Errorf("unable to get object attribute: %v", err)
	}
	currentTimestamp := time.Now().Unix()
	diff := currentTimestamp - timestamp
	assert.LessOrEqual(t, diff, int64(30000), "expect timestamp to be within last 30 seconds")
}
