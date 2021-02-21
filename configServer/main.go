package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"io/ioutil"
	"path/filepath"
    "sigs.k8s.io/yaml"
	"os"
	"github.com/golang/glog"
	"net/http"
	"strings"
	"crypto/sha512"
	"encoding/hex"
	"encoding/json"
	"github.com/imdario/mergo"
//	"io"
//	"encoding/base64"
	"net"
)


type Config struct {
	UserFolders []string `json:"userFolders,omitempty"`
	Users map[string]User `json:"users"`
	PropertiesFolders []string `json:"propertiesFolders,omitempty"`
	Properties map[string]map[string]interface{} `json:"properties"`
	Server Server `json:"server"`
}

type User struct {
	Groups		[]string `json:groups,omitempty`
}


type Server struct {
	Auth Auth `json:"auth,omitempty"`
	Tls Tls `json:"tls,omitempty"`
	Listen string `json:"listen,omitempty`
}

type Auth struct {
	Credentials map[string]string `json:"credentials,omitempty"`
	Mtls []Mtls `json:"mtls,omitempty"`
}

type CaFilters struct {
	CommonName string `json:"commonName,omitempty"`
	Organisation []string `json:"organization,omitempty"`
	OrganizationUnit []string `json:"organizationUnit,omitempty"`
}

type Mtls struct {
	Ca string `json:"ca,omitempty`
}

type Tls struct {
	CertFile string `json:"cert,omitempty"`
	KeyFile string `json:"key,omitempty"`
}

type ConfigRequest struct {
    Username string `json:"username"`
    SessionID string `json:"sessionId"`
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

func configHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	if (len(r.TLS.VerifiedChains) > 0 ||  basicAuth(w, r)) {
		reqBody, _ := ioutil.ReadAll(r.Body)
		var req ConfigRequest
	    json.Unmarshal(reqBody, &req)
		user, ok := cfg.Users[req.Username]
		if !ok {
			w.WriteHeader(500)
			return
		}
		var merged map[string]interface{}
		for _, group := range user.Groups {
			conf, ok := cfg.Properties[group]
			if !ok {
				w.WriteHeader(500)
				return
			}
			if err := mergo.Merge(&merged, conf, mergo.WithOverride); err != nil {
				w.WriteHeader(500)
				return
 	       }
		}
		json.NewEncoder(w).Encode(merged)
	}
	return
}

func main() {
	http.HandleFunc("/config", configHandler)
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
			
			tlsConfig := &tls.Config{
				ClientCAs: caCertPool,
				ClientAuth: tls.VerifyClientCertIfGiven,
				// VerifyPeerCertificate: mtlsAuth,
			}
			tlsConfig.BuildNameToCertificate()

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
		if err != nil {
			glog.Fatalf("Config parse error: %v", err)
			os.Exit(-1)
		}
		err = yaml.Unmarshal(yamlFile,&cfg)
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

