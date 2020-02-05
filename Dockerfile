################################################################################
## GO BUILDER
################################################################################
FROM golang:1.13.6 as builder

ENV VERSION 1.7.1
ENV BUILD_DIR /build

RUN mkdir -p ${BUILD_DIR}
WORKDIR ${BUILD_DIR}

COPY go.* ./
RUN go mod download
COPY . .

RUN go test -cover ./...
RUN CGO_ENABLED=0 go build -a -tags netgo -installsuffix netgo -ldflags "-X github.com/halverneus/static-file-server/cli/version.version=${VERSION}" -o /serve /build/bin/serve

RUN adduser --system --no-create-home --uid 1000 --shell /usr/sbin/nologin static
RUN setcap cap_net_bind_service=+ep /serve

################################################################################
## DEPLOYMENT CONTAINER
################################################################################
FROM scratch

EXPOSE 8080
COPY --from=builder /serve /
COPY --from=builder /etc/passwd /etc/passwd

USER static
ENTRYPOINT ["/serve"]
CMD []

# Metadata
LABEL life.apets.vendor="Halverneus" \
    life.apets.url="https://github.com/halverneus/static-file-server" \
    life.apets.name="Static File Server" \
    life.apets.description="A tiny static file server" \
    life.apets.version="v1.7.1" \
    life.apets.schema-version="1.0"
