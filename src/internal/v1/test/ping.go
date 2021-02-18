package test

import (
	"net/http"

	"github.com/HqOapp/go-service/alice/middleware"
	"github.com/HqOapp/go-service/service"
)

type PongResponse struct {
	Message string `json:"message"`
}

// Ping returns a ping handler
func Ping() http.Handler {
	return middleware.HandlerFunc(func(w http.ResponseWriter, r *http.Request) error {
		ret := PongResponse{Message: "pong!"}
		return service.WriteJSONResponse(w, http.StatusOK, ret)
	})
}
