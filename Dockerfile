# CONTAINER FOR BUILDING BINARY
FROM golang:1.21 AS build

# INSTALL DEPENDENCIES
RUN go install github.com/gobuffalo/packr/v2/packr2@v2.8.3
COPY go.mod go.sum /src/
RUN cd /src && go mod download

# BUILD BINARY
COPY . /src
RUN cd /src && make build

# CONTAINER FOR RUNNING BINARY
FROM alpine:3.19.0

ARG USER=seqsender
RUN adduser -D $USER
USER $USER
WORKDIR /app

COPY --from=build --chown=$USER --chmod=100 /src/dist/zkevm-seqsender .

RUN mkdir -p data && chown $USER. data
VOLUME ["/app/data"]

CMD ["/app/zkevm-seqsender run"]
