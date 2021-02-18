# Do not extend anymore functionality to this make file. It will be replaced.
check-swagger:
	which swagger || (GO111MODULE=off go get -u github.com/go-swagger/go-swagger/cmd/swagger)

swagger: check-swagger
	go mod vendor && swagger generate spec -o ./doc/swagger/v1/swagger.json --scan-models

serve-swagger: check-swagger
	swagger serve -F=swagger ./doc/swagger/v1/swagger.json
