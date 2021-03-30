# Project Structure
## Database Migrations
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

## Service Code
### Service Runner
When the service is run, the `/src/main/server.go` file is used as the execution entry point. You should seldom need
to alter this file.

### Defining Service Routes
All routes are defined in `/src/server/<serviceName>/routes.go`. Refer to the [vestigo](https://github.com/husobee/vestigo)
documentation for more information.

### Database Layer
Code to query the database goes into `/src/internal/data/database.go` with corresponding unit tests in
`/src/internal/data/database_test.go`.

### Route Handlers
Code to handle the routes your service provides goes into `/src/internal/v1/`. This directory will contain sub-directories
named after the path of your route. Each sub-directory will contain a Go file for the various actions the route responds to.
As an example, this template contains a `/src/internal/v1/test/ping.go` file to handle the route `/<serviceName>/v1/test/ping`.

### Service Client
The service client is a package other services can import to make calls to your service. The routes you choose
to expose have methods in `/src/<serviceName>/client.go`.

### Error Codes / Messages
Database specific error codes and messages are defined in `/src/internal/data/errors.go`. All other error codes and
messages are defined in `/src/<serviceName>/errors.go`.

### Request, Response, and Other Structures
All other structures are typically defined in `/src/<serviceName>/`.
