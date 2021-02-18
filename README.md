# hello-go
This repository serves as a template for creating a new service powered by [Go](https://golang.org/) and a
[PostgreSQL](https://www.postgresql.org/) database.

## Using this template
### Create a New GitHub Repository for the Service
When you [create a new repository](https://github.com/new) in GitHub, select `HqOapp/hello-go` in the
`Repository template` drop-down.

![Create new GitHub repo from template](/doc/new-service-repo.png?raw=true "Create new GitHub repo from template")

### Clone the Repository Locally
```sh
git clone git@github.com:HqOapp/<my_new_service_name>.git
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
git push -u origin main
```

# <serviceName>-service
An API for creating White-label releases

## Prerequisites
Check if Golang is installed
```sh
go version
```

Install Golang if necessary
```sh
brew install go
```
other installation ways are described [here](https://golang.org/doc/install)

Install PgAdmin PostgresSQL administration tool
```sh
brew install --cask pgadmin4
```

Check if NodeJS is installed
```sh
node --version
```

Install Nodejs if necessary
```sh
brew install node
```

Install yarn package manager
```sh
brew install yarn
```

## Getting Started
Clone repo
```sh
git clone git@github.com:HqOapp/<serviceName>-service.git
```

Go to the project folder
```sh
cd <serviceName>-service
```

Login to devspace
```sh
yarn devspace:login
```

Start devspace
```sh
yarn devspace:start
```

Create secret.env file into the config folder and ask somebody to share its content with you

Add private repository path to the go environment
```sh
go env -w GOPRIVATE="github.com/HqOapp"
```

Run database migrations and start <serviceName> in different terminal session
```sh
build/migrate.sh
build/run.sh
```

## Start <serviceName>-service on a public URI
To start <serviceName>-service on a public URI, run the following commands:  
`yarn devspace:deploy production`

This starts <serviceName>-service using the master branch and makes it available at `https://<your-github-username>-<serviceName>-service.gloo.hqo.dev`.

To start <serviceName>-service from a specific branch do the following:  
`DOCKER_TAG=<githash for the branch> yarn devspace:deploy production`

Example: https://john-doe-<serviceName>-service.gloo.hqo.dev

**NOTE**: make sure you stop the service when it is no longer needed.

`yarn devspace:stop`

## Using Swagger
Install go-swagger

```
brew tap go-swagger/go-swagger
brew install go-swagger
```

Update vendor folder
```
go mod vendor
```

Generate Swagger Docs by running the following command in <serviceName>-service's root
```
make swagger
```

Start Swagger UI by running the following command in <serviceName>-service's root
```
make serve-swagger
```
NOTE: These commands are in <root>/makefile. Using makefile is temporary until we find a better solution.

## Adding Swagger documentation
Refer to [goswagger's documentation for tag information](https://goswaggerio/use/spec.html)

To add documentation for an endpoint, do the following:
1. create a matching GO file in <root>/src/internal/v1/swagger (ex: branches.go)
2. Fill in Swagger meta information describing the endpoint
3. Generate the documentation by running ```make swagger```
4. Start Swagger UI by running ```make serve-swagger```
5. Test the endpoint reference in Swagger UI to verify the endpoint documentation is configured correctly

## Project Structure
### Database Migrations
Database migrations are placed in the `build/migration/` directory. Migration files are divided into two categories:
migrations only run once and migrations run every time the service is brought up. The files follow these naming
conventions.

Single run migration files are
- prefixed with a numeric string beginning at `0001_` followed by an underscore with each file incrementing the numeric
  prefix
- suffixed with the extension `.up.sql` or `.down.sql`

**Examples:** `0001_people.up.sql`, `0001_people.down.sql`, `0002_companies.up.sql`

Always run migration files are
- prefixed with a numeric string beginning at `10002_` followed by an underscore with each file incrementing the numeric
  prefix
- suffixed with the extension `.alwauysup.sql`

**Examples:** `10002_get_people.alwaysup.sql`, `10003_delete_companies.alwaysup.sql`

### Service Code
#### Service Runner
When the service is run, the `/src/main/server.go` file is used as the execution entry point. You should seldom need
to alter this file.

#### Defining Service Routes
All routes are defined in `/src/server/<my_new_service_name>/routes.go`. Refer to the [vestigo](https://github.com/husobee/vestigo)
documentation for more information.

#### Database Layer
Code to query the database goes into `/src/internal/data/database.go` with corresponding unit tests in
`/src/internal/data/database_test.go`.

#### Route Handlers
Code to handle the routes your service provides goes into `/src/internal/v1/`. This directory will contain sub-directories
named after the path of your route. Each sub-directory will contain a Go file for the various actions the route responds to.
As an example, this template contains a `/src/internal/v1/test/ping.go` file to handle the route `/<my_new_service_name>/v1/test/ping`.

#### Service Client
The service client is a package other services can import to make calls to your service. The routes you choose
to expose have methods in `/src/<my_new_service_name>/client.go`.

#### Error Codes / Messages
Database specific error codes and messages are defined in `/src/internal/data/errors.go`. All other error codes and
messages are defined in `/src/<my_new_service_name>/errors.go`.

#### Request, Response, and Other Structures
All other structures are typically defined in `/src/<my_new_service_name>/`.
