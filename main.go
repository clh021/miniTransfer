package miniTransfer

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
)

var mem_fileSavePath string = ""

func getFileSavePath() string {
	if len(mem_fileSavePath) == 0 {
		default_save_path := "/tmp/"
		env_name := "MINI_TRANSFER_FILE_PATH"
		env_path, exist := os.LookupEnv(env_name)
		if !exist {
			log.Printf("No env `%s` set. You can set like default `%s`", env_name, default_save_path)
		} else {
			if len(env_path) > 0 {
				mem_fileSavePath = env_path
				EnsureDir(filepath.Dir(env_path))
				log.Printf("Use env `%s` get file save path: %s \n", env_name, env_path)
			} else {
				mem_fileSavePath = default_save_path
				log.Printf("Empty env `%s` set to use default path: %s \n", env_name, default_save_path)
			}
		}
	}
	return mem_fileSavePath
}

func EnsureDir(baseDir string) error {
	info, err := os.Stat(baseDir)
	if err == nil && info.IsDir() {
		return nil
	}
	return os.MkdirAll(baseDir, 0755)
}

func FileHandler(w http.ResponseWriter, r *http.Request) {
	savePath := filepath.Join(getFileSavePath(), r.URL.Path)

	if r.Method == http.MethodGet {
		http.ServeFile(w, r, savePath)
		log.Printf(" ▽ : %s\n", savePath)
	} else {
		b, err := ioutil.ReadAll(r.Body)
		if err != nil {
			w.WriteHeader(500)
			_, _ = w.Write([]byte(fmt.Sprintf("%s", err)))
			return
		}

		err = ioutil.WriteFile(savePath, b, 0644)
		if err != nil {
			w.WriteHeader(500)
			_, _ = w.Write([]byte(fmt.Sprintf("%s", err)))
			return
		}

		w.WriteHeader(200)
		_, _ = w.Write([]byte(fmt.Sprintf("OK %s", savePath)))
		log.Printf(" △ : %s\n", savePath)
	}
}
