package miniTransfer

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"path/filepath"
)

func FileHandler(w http.ResponseWriter, r *http.Request, basePath string) {
	filePath := filepath.Join(basePath, r.URL.Path)
	if r.Method == http.MethodGet {
		http.ServeFile(w, r, filePath)
		log.Printf("download file %s\n", filePath)
	} else {
		b, err := ioutil.ReadAll(r.Body)
		if err != nil {
			w.WriteHeader(500)
			_, _ = w.Write([]byte(fmt.Sprintf("%s", err)))
			return
		}

		err = ioutil.WriteFile(filePath, b, 0644)
		if err != nil {
			w.WriteHeader(500)
			_, _ = w.Write([]byte(fmt.Sprintf("%s", err)))
			return
		}

		w.WriteHeader(200)
		_, _ = w.Write([]byte(fmt.Sprintf("OK %s", filePath)))
		log.Printf("upload file %s\n", filePath)
	}
}
