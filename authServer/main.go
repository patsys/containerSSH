package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"io/ioutil"
	"path/filepath"
	"gopkg.in/yaml.v2"
	"os"
	"github.com/golang/glog"
	"net/http"
	"strings"
	"crypto/sha512"
	"encoding/hex"
	"encoding/json"
	"io"
	"encoding/base64"
	"net"
)


type Config struct {
	UserFolders []string `yaml:"userFolders,omitempty"`
	Users map[string]User `yaml:"users"`
	Server Server `yaml:"server"`
}

type User struct {
	Password	string `yaml:"password,omitempty"`
	PublicKeys	[]string `yaml:"publicKeys,omitempty"`
	Ips			[]string `yaml:ips,omitempty`
	Groups		[]string `yaml:groups,omitempty`
}


type Server struct {
	Auth Auth `yaml:"auth,omitempty"`
	Tls Tls `yaml:"tls,omitempty"`
	Listen string `yaml:"listen,omitempty`
}

type Auth struct {
	Credentials map[string]string `yaml:"credentials,omitempty"`
	Mtls []Mtls `yaml:"mtls,omitempty"`
}

type CaFilters struct {
	CommonName string `yaml:"commonName,omitempty"`
	Organisation []string `yaml:"organization,omitempty"`
	OrganizationUnit []string `yaml:"organizationUnit,omitempty"`
}

type Mtls struct {
	Ca string `yaml:"ca,omitempty`
}

type Tls struct {
	CertFile string `yaml:"cert,omitempty"`
	KeyFile string `yaml:"key,omitempty"`
}

type PasswordRequest struct {
    Username string `json:"username"`
    PasswordBase64 string `json:"passwordBase64"`
    ConnectionId string `json:"connectionId"`
    RemoteAddress string `json:"remoteAddress"`
}

type PubkeyRequest struct {
    Username string `json:"username"`
    PublicKey string `json:"publicKey"`
    ConnectionId string `json:"connectionId"`
    RemoteAddress string `json:"remoteAddress"`
}

var (
	cfg = &Config{}
	configFlag string
)

func basicAuth(w http.ResponseWriter, r *http.Request) bool {

	u, p, ok := r.BasicAuth()
	if !ok {
		w.WriteHeader(401)
		return false
	}
	password, exist := cfg.Server.Auth.Credentials[u]
	if !exist {
		w.WriteHeader(401)
		return false
	}
	hashSum := sha512.Sum512([]byte(p))
	if  hex.EncodeToString(hashSum[:]) != password {
		w.WriteHeader(401)
		return false
	}
	return true
}

func checkIp(remoteIp string, ips []string) bool {
	if len(ips) == 0 { return true }
	    ip := net.ParseIP(remoteIp)
	for _, cidr := range ips {
		_, subnet, error := net.ParseCIDR(cidr)
		if error != nil { return false }
		if subnet.Contains(ip) {
			return true
		}
	}
	return false
}

func passwordHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if (len(r.TLS.VerifiedChains) > 0 ||  basicAuth(w, r)) {
		reqBody, _ := ioutil.ReadAll(r.Body)
		var req PasswordRequest
	json.Unmarshal(reqBody, &req)
		user, ok := cfg.Users[req.Username]
		if !ok {
			io.WriteString(w, "{\"success\": false }\n")
			return
		}

		password, error :=  base64.URLEncoding.DecodeString(req.PasswordBase64)
	    if error != nil {
			io.WriteString(w, "{\"success\": false }\n")
			return
		}

		hashSum := sha512.Sum512(password)
		if hex.EncodeToString(hashSum[:]) !=  user.Password {
			io.WriteString(w, "{\"success\": false }\n")
			return
		} else {
			if checkIp(req.RemoteAddress, user.Ips){
				io.WriteString(w, "{\"success\": true }\n")
				return
			}
		}
	}

	io.WriteString(w, "{\"success\": false }\n")
	return
}

func pubkeyHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if (len(r.TLS.VerifiedChains) > 0 || basicAuth(w, r)) {
		reqBody, _ := ioutil.ReadAll(r.Body)
		var req PubkeyRequest
	json.Unmarshal(reqBody, &req)
		user, ok := cfg.Users[req.Username]
		if !ok {
			io.WriteString(w, "{\"success\": false }\n")
			return
		}
		for _, pubKey := range user.PublicKeys {
			if (req.PublicKey == pubKey) {
				if checkIp(req.RemoteAddress, user.Ips){
					io.WriteString(w, "{\"success\": true }\n")
					return
				}
			}
		}
	}

	io.WriteString(w, "{\"success\": false }\n")
	return
}

func main() {
	http.HandleFunc("/password", passwordHandler)
	http.HandleFunc("/pubkey", pubkeyHandler)
	if cfg.Server.Listen == "" {
		if (cfg.Server.Tls == Tls{}) {
		  cfg.Server.Listen = ":8080"
		} else {
		  cfg.Server.Listen = ":8443"
		}
	}
	if (cfg.Server.Tls == Tls{}) {
		glog.Fatal(http.ListenAndServe(cfg.Server.Listen, nil));
	} else {
		if (len(cfg.Server.Auth.Mtls) == 0) {
			glog.Fatal(http.ListenAndServeTLS(cfg.Server.Listen, cfg.Server.Tls.CertFile, cfg.Server.Tls.KeyFile, nil))
		} else {
			caCertPool := x509.NewCertPool()
			for _, mtls := range cfg.Server.Auth.Mtls {
				caCert, err := ioutil.ReadFile(mtls.Ca)
				if err != nil {
					glog.Fatal(err.Error())
				}
				caCertPool.AppendCertsFromPEM(caCert)
			}
			// Create the TLS Config with the CA pool and enable Client certificate validation
			tlsConfig := &tls.Config{
				ClientCAs: caCertPool,
				ClientAuth: tls.VerifyClientCertIfGiven,
				// VerifyPeerCertificate: mtlsAuth,
			}
			tlsConfig.BuildNameToCertificate()

			// Create a Server instance to listen on port 8443 with the TLS config
			server := &http.Server{
				Addr:      cfg.Server.Listen,
				TLSConfig: tlsConfig,
			}

			glog.Fatal(server.ListenAndServeTLS(cfg.Server.Tls.CertFile, cfg.Server.Tls.KeyFile))
		}
	}

}

func init() {

	flag.StringVar(&configFlag, "config", "", "configFile")

	flag.Parse()

	if configFlag != "" {
		yamlFile, err := ioutil.ReadFile(configFlag)
		if err != nil {
			glog.Fatalf("Cannot get config file %s Get err   #%v ", configFlag, err)
			os.Exit(-1)
		}
		err = yaml.Unmarshal(yamlFile, &cfg)
		if err != nil {
			glog.Fatalf("Config parse error: %v", err)
			os.Exit(-1)
		}
	}else{
		glog.Fatalf("Need a config file")
		os.Exit(-1)
	}

	if cfg == nil {
		glog.Fatalf("Config file can not be empty")
		os.Exit(-1)
	}

	if cfg.UserFolders == nil { cfg.UserFolders = []string{} }
	if cfg.Users == nil { cfg.Users = make(map[string]User) }

	for _, path := range cfg.UserFolders {
		err := filepath.Walk(path, func(path string, info os.FileInfo, err error) error {
			user := User{}
			if filepath.Ext(info.Name()) == ".yml" {
				yamlFile, err := ioutil.ReadFile(configFlag)
				if err != nil {
					glog.Fatalf("Cannot get config file %s Get err   #%v ", path, err)
					return err
				}
				err = yaml.Unmarshal(yamlFile, &user)
				if err != nil {
					glog.Fatalf("Config parse error: %s", err)
					return err
				}
				cfg.Users[strings.TrimSuffix(info.Name(), ".yml")] = user
			}
			return nil
		})
		if err != nil {
			os.Exit(-1)
		}
	}
}
