//go:generate swagger generate spec -o ../../doc/swagger/v1/swagger.json --scan-models

package main

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
	"os"

	"github.com/divideandconquer/go-consul-client/src/balancer"
	"github.com/healthimation/go-env-config/src/client"
	"github.com/opentracing/opentracing-go"

	"github.com/HqOapp/<serviceName>-service/src/server/<serviceName>"
	_ "github.com/HqOapp/<serviceName>-service/src/internal/v1/swagger"
	"gopkg.in/DataDog/dd-trace-go.v1/ddtrace/opentracer"
	"gopkg.in/DataDog/dd-trace-go.v1/ddtrace/tracer"
)

// config keys
const (
	configKeyEnvironment = "ENVIRONMENT"
	configKeyServiceMap = "SERVICE_MAP"
	configKeyDataDogAgentHost = "DD_AGENT_HOST"
	configKeyDataDogAgentPort = "DD_AGENT_PORT"
)

func main() {
	// pull environment from env vars
	env := os.Getenv(configKeyEnvironment)
	if len(env) == 0 {
		log.Fatal("environment not set")
	}

	//Setup ENV config loader implementation
	conf := client.NewEnvLoader()

	// Setup balancer implementation
	var serviceMap map[string]string
	serviceMapBy, err := conf.Get(configKeyServiceMap)
	if err != nil {
		log.Fatalf("Could not find config for %s", configKeyServiceMap)
	}
	err = json.Unmarshal(serviceMapBy, &serviceMap)
	if err != nil {
		log.Fatalf("Error decoding %s config %s", configKeyServiceMap, err.Error())
	}
	b := balancer.NewMapBalancer(serviceMap)

	// Setup datadog agent
	ddAgentHost := os.Getenv(configKeyDataDogAgentHost)
	if len(ddAgentHost) == 0 {
		log.Fatal("data dog host not set")
	}

	ddAgentPort := os.Getenv(configKeyDataDogAgentPort)
	if len(ddAgentPort) == 0 {
		log.Fatal("data dog port not set")
	}

	ddAddr := net.JoinHostPort(
		ddAgentHost,
		ddAgentPort,
	)

	t := opentracer.New(tracer.WithServiceName("<serviceName>"), tracer.WithAnalytics(true), tracer.WithAgentAddr(ddAddr))
	defer tracer.Stop()
	opentracing.SetGlobalTracer(t)

	svr := <serviceName>.NewServer(env, <serviceName>.DefaultServiceName, conf, b)

	// Start up the server
	log.Printf("Starting %s %s", env, <serviceName>.DefaultServiceName)
	log.Fatal(http.ListenAndServe(":8080", svr.GetRouter()))
}
