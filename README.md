# hello-go
This repository serves as a template for creating a new service powered by [Go](https://golang.org/) and a
[PostgreSQL](https://www.postgresql.org/) database.

## Using this template
### Create a New GitHub Repository for the Service
Create a ticket in [Alpha Team backlog](https://ventureapp.atlassian.net/secure/RapidBoard.jspa?rapidView=125&projectKey=AT&view=planning&selectedIssue=AT-16&issueLimit=100)
with the label `tech-ops` asking for a new repository called `<my_new_service_name>-service` (ensure the name conforms to
[Go standards](https://blog.golang.org/package-names)) to be created using this `hello-go` repository as the template.

![Create new GitHub repo from template](/doc/new-service-repo.png?raw=true "Create new GitHub repo from template")

### Clone the Repository Locally
Once the new repository has been created by DevOps, you can clone it locally.
```sh
git clone git@github.com:HqOapp/<my_new_service_name>-service.git
```

### Initialize the Service
Now that you have the service cloned locally, you will need to initialize the service to use your service's
name. The commands below will update the project files with that name.

```sh
cd new-service
sh init.sh <my_new_service_name>
```

### Update this README
Remove all the `hello-go` section and these `Using this template` instructions. Provide details on what your service
does, how to run it locally, development guidelines, etc. below.

### Check in the Updated Service
Make sure to check all the changes into GitHub.

```sh
git add *
git commit -m "initial clone"
git push -u origin master
```

# <serviceName>-service
This service does <FILL IN DETAILS HERE>

## Table of Contents
* [Getting Started](#getting-started)
  * [Development Environment Setup](#development-environment-setup)
  * [Clone and Configure the Service](#clone-and-configure-the-service)
* [Using the Service](#using-the-service)
  * [Start the Database](#start-the-database)
  * [Start the Service](#start-the-service)
  * [Start the Swagger UI](#start-the-swagger-ui)
  * [Stop the Service, Database, and Swagger UI](#stop-the-service-database-and-swagger-ui)
* [Running Tests](#running-tests)
* [Running Code Correctness Tools](#running-code-correctnes-tools)
* [Development Resources](#development-resources)

## Getting Started
### Development Environment Setup
You will need to have the following tools installed on your local environment:
* [Go](https://golang.org/)
* [node.js](https://nodejs.org/)
* [yarn](https://yarnpkg.com/)
* [curl](https://curl.se/)
* [go-swagger](https://goswagger.io/)

You can quickly install all of these tools via [Homebrew](https://brew.sh/) on macOS.
```shell
brew install go
brew install node
brew install yarn
brew install curl
brew tap go-swagger/go-swagger
brew install go-swagger
```

Once Go is installed, add HqO's private repository path to the Go environment.
```shell
go env -w GOPRIVATE="github.com/HqOapp"
```

Login to [DevSpace](https://devspace.cloud/) to ensure you can bring up the service's resources.
```shell
yarn devspace:login
```

The team recommends using [pgAdmin](https://www.pgadmin.org/) to connect to your development database instance, but any
database client will work.
```shell
brew install --cask pgadmin4
```

### Clone and Configure the Service
Clone the service locally.
```shell
git clone git@github.com:HqOapp/<serviceName>-service.git
cd <serviceName>-service
```

Install the node.js based dependencies.
```shell
yarn install
```

Create a `secret.env` file in the `/config` directory.
```shell
touch config/secret.env
```

The file should contain the following key / value pairs. Ask a team member for the appropriate values to use.
```yaml
JWT_SECRET='"<JWT token here>"'
GITHUB_AUTH_TOKEN='"fake"'
SERVICE_MAP='{"<serviceName>-db":"127.0.0.1:5432"}'
DB_USER='"<db username here>"'
DB_PASSWORD='"<db password here>"'
LOG_LEVEL=7
USE_CORS=true
ENVIRONMENT=local
```

## Using the Service
### Start the Database
```shell
yarn devspace:start
```

Once your instance is running, you can connect to it using your preferred SQL client. The server name to use is
`localhost`. The username and password for connecting are the same you used in your `secret.env` file.

### Start the Service
You will need to open a separate terminal window to run the database migrations and start the service.
```shell
build/migrate.sh && build/run.sh
```

The service will be available at `http://localhost:8080/`. You can verify it is responding by hitting the heartbeat
endpoint.
```shell
curl -sSL http://localhost:8080/v1/test/ping
```

You should receive the following in response.
```json
{"message":"pong!"}
```

### Start the Swagger UI
We use [Swagger](https://swagger.io/) to document the service's API. The `go-swagger` module allows us to bring up a
local version of the Swagger documentation UI. This UI allows us to test our endpoints. Open up a third terminal window
and build the Swagger documentation.
```shell
yarn swagger:build
```

Now, you can start up the Swagger UI.
```shell
yarn swagger:serve
```

This will bring up the UI in a page, typically the URL `http://localhost:58913/docs`, within your default web browser.

### Stop the Service, Database, and Swagger UI
You can `Ctrl-C` out of the running processes for the service, database, and Swagger. This will bring down the service
itself but leave the database instance running on DevSpace. You should always tear down the database in DevSpace, when
you no longer need it.
```shell
yarn devspace:stop
```

## Running Tests
You can run all unit, integration, and functional tests. The verbose mode will display the details of the test cases
run.
```shell
yarn test
yarn test:verbose
```

You can also run specific types of tests.
```shell
yarn test:unit
yarn test:unit:verbose

yarn test:integration
yarn test:integration:verbose

yarn test:functional
yarn test:functional:verbose
```

## Running Code Correctness Tools
Run [golint](https://github.com/golang/lint) and [vet](https://golang.org/pkg/cmd/vet/) the code.

```shell
yarn lint
yarn vet
```

## Development Resources
* [Project Structure](doc/project_structure.md)
* [Adding Swagger Documentation](doc/swagger.md)
* [Start the service on a public URI](doc/public_uri.md)
