package main

import (
	"log"
	"net/http"
	"os"

	"github.com/divideandconquer/go-consul-client/src/balancer"
	"github.com/divideandconquer/go-consul-client/src/config"
)

// config keys
const (
	configKeyEnvironment = "ENVIRONMENT"
	configKeyServiceMap = "SERVICE_MAP"
)

func main() {
	// pull environment from env vars
	env := os.Getenv(configKeyEnvironment)
	if len(env) == 0 {
		log.Fatal("environment not set")
	}

	//Setup config loader implementation
	//TODO switch to a real config loader.
	conf, err := config.NewMappedLoader([]byte(`{"SERVICE_MAP":{},"USE_CORS":true,"DB_USER":"postgres","DB_PASSWORD":"password"}`))
	if err != nil {
		log.Fatalf("Error parsing config: %v", err)
	}

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

	svr := <serviceName>.NewServer(env, <serviceName>.DefaultServiceName, conf, b)

	// Start up the server
	log.Printf("Starting %s %s", env, <serviceName>.DefaultServiceName)
	log.Fatal(http.ListenAndServe(":8080", svr.GetRouter()))
}
