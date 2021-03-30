# Adding Swagger Documentation
Refer to [goswagger's documentation for tag information](https://goswaggerio/use/spec.html)

To add documentation for an endpoint, do the following:
1. Create a matching Go file in `<root>/src/internal/v1/swagger` (e.g., `branches.go`).
2. Fill in Swagger meta information describing the endpoint.
3. Generate the documentation by running ```yarn swagger:build```.
4. Start the Swagger UI by running ```yarn swagger:serve```.
5. Test the endpoint reference in the Swagger UI to verify the endpoint documentation is configured correctly.
