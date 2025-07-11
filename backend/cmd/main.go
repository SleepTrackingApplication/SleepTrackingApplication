package main

import (
	"log"

	"backend/pkg"
)

func main() {
	server := new(pkg.Server)
	if err := server.Start(); err != nil {
		log.Fatalf("Error with starting server %v", err.Error())
	}
}
