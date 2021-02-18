//nolint // swagger gets a pass
package swagger

import (
	"github.com/HqOapp/<serviceName>-service/src/internal/v1/test"
)

// swagger:route GET /test/ping ping-pong smoke-test
// Returns the string "pong" if the service is running
// responses:
//   200: PongResponse

// A list of build systems as a string array
// swagger:response buildSystemResponse
type pongResponseWrapper struct {
	// in:body
	Body test.PongResponse
}
