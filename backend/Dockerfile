FROM golang:1.23-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o backend cmd/server/main.go && chmod +x ./backend

EXPOSE 8080

CMD ["./backend"]