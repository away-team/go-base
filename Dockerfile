FROM golang:1.15 as build

ENV GOPRIVATE=github.com/hqoapp
ENV GO111MODULE=on
ENV GOPATH=

ADD https://github.com/envkey/envkey-source/releases/download/v1.2.9/envkey-source_1.2.9_linux_amd64.tar.gz .
RUN tar zxf envkey-source_1.2.9_linux_amd64.tar.gz envkey-source && rm envkey-source_1.2.9_linux_amd64.tar.gz
RUN chmod +x envkey-source

ARG GITHUB_USER
ARG GITHUB_TOKEN
RUN echo "machine github.com login ${GITHUB_USER} password ${GITHUB_TOKEN}" > ~/.netrc

COPY go.mod go.sum ./
RUN go mod tidy
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -a -ldflags "-s" -installsuffix cgo -o bin/app src/main/*.go

#######################################################################################################################

FROM golang:1.15

COPY --from=build /go/envkey-source /usr/local/bin/envkey-source
COPY --from=build /go/entrypoint.sh .
COPY --from=build /go/bin/app /app

EXPOSE 8080
ENTRYPOINT [ "./entrypoint.sh" ]
CMD [ "/app" ]
