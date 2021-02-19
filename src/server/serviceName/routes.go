package <serviceName>

import (
	"net/http"

	"github.com/divideandconquer/go-consul-client/src/balancer"
	"github.com/divideandconquer/go-consul-client/src/config"
	"github.com/husobee/vestigo"

	"github.com/HqOapp/go-auth/validation"
	"github.com/HqOapp/go-service/alice/chain"
	"github.com/HqOapp/go-service/service"
)

// config keys
const (
	configKeyDBUser     = "DB_USER"
	configKeyDBPassword = "DB_PASSWORD"
	configKeyUseCORS    = "USE_CORS"
	configKeyLogLevel   = "LOG_LEVEL"
	configKeyJwtSecret  = "JWT_SECRET"
)

// DefaultServiceName is used in 99% of cases
const DefaultServiceName = "<serviceName>"

type server struct {
	environment string
	serviceName string
	router      *vestigo.Router
	conf        config.Loader
	balancer    balancer.DNS
	validator   validation.Validator
}

// NewServer returns a Server
func NewServer(env, serviceName string, conf config.Loader, lb balancer.DNS) service.Server {
	jwtSecret := conf.MustGetString(configKeyJwtSecret)
	validator := validation.NewValidator(jwtSecret)

	ret := &server{
		environment: env,
		serviceName: serviceName,
		conf:        conf,
		balancer:    lb,
		validator:   *validator,
	}
	ret.init()
	return ret
}

func (s *server) Authorize(h http.Handler) http.Handler {
	handler := func(w http.ResponseWriter, r *http.Request) {
		// authentication
		_, err := s.validator.ValidateRequest(r)
		if err != nil {
			http.Error(w, "You do not have access to this endpoint.", http.StatusUnauthorized)
			return
		}

		h.ServeHTTP(w, r)
	}

	return http.HandlerFunc(handler)
}

func (s *server) init() {
	useCORS := s.conf.MustGetBool(configKeyUseCORS)

	// !!!! REMOVE THIS COMMENT AND UNCOMMENT THE BLOCK BELOW TO ENABLE LOGGING AND WRAP YOUR ROUTES WITH IT !!!!
	// logLevel := s.conf.MustGetInt(configKeyLogLevel)
	// log := middleware.GetDefaultLogger(s.serviceName, s.environment, logLevel)

	// !!!! REMOVE THIS COMMENT AND UNCOMMENT THE BLOCK BELOW TO ENABLE THE DB !!!!
	// dbUser := s.conf.MustGetString(configKeyDBUser)
	// dbPass := s.conf.MustGetString(configKeyDBPassword)
	// dbFactory := data.GetDBFactory(s.balancer, dbUser, dbPass, s.serviceName, log)

	// To track timer metrics setup and pass in a timer instead of nil
	// !!!! REMOVE THIS COMMENT TO ENABLE METRICS AND WRAP YOUR ROUTES WITH IT !!!!
	// b := chain.NewBaseWithExtras(alice.New(), trace.NewOpenTracingTimer(), middleware.NewLogrusLogger(log, true), jwtdecode.NewJWTDecoder(), s.Authorize)

	// error handlers
	vestigo.CustomNotFoundHandlerFunc(chain.NotFoundHandler)
	vestigo.CustomMethodNotAllowedHandlerFunc(chain.MethodNotAllowedHandler)

	router := vestigo.NewRouter()
	if useCORS {
		router.SetGlobalCors(&vestigo.CorsAccessControl{
			AllowOrigin:      []string{"*"},
			AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"},
			AllowHeaders:     []string{"DNT", "Keep-Alive", "User-Agent", "X-Requested-With", "If-Modified-Since", "Cache-Control", "Content-Type", "Accept", "Authorization"},
			ExposeHeaders:    []string{"Content-Length"},
			AllowCredentials: false,
		})
	}

	// Below is an example of how to use the the chain with logging and metrics.
	// router.Get("/v1/test/ping", b.Measure("ping", test.Ping()))

	// Setup routes
	router.Get("/v1/test/ping", test.Ping().ServeHTTP)

	s.router = router
}

func (s *server) GetRouter() *vestigo.Router {
	return s.router
}
func (s *server) GetEnvironment() string {
	return s.environment
}
func (s *server) GetServiceName() string {
	return s.serviceName
}
