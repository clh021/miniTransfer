package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"

	"github.com/clh021/miniTransfer"
)

var build = "not set"

var port int

// upload file
// > curl -T filename.txt 127.0.0.1:1234
// downlod file
// > curl 127.0.0.1:1234/filename.txt
func main() {
	fmt.Printf("[BUILD_INFO]: %s\n", build)
	flag.IntVar(&port, "port", 1234, "set port")
	flag.Parse()

	http.HandleFunc("/", miniTransfer.FileHandler)

	log.Printf("starting server at port %d\n", port)
	err := http.ListenAndServe(fmt.Sprintf(":%d", port), nil)
	if err != nil {
		log.Println(err)
	}
}
