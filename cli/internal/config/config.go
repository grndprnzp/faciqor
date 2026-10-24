package config

import (
	"os"
	"path/filepath"

	"github.com/spf13/viper"
)

type Config struct {
	Endpoint   string `mapstructure:"endpoint" json:"endpoint"`
	Token      string `mapstructure:"token" json:"token"`
	DefaultOrg string `mapstructure:"default_org" json:"default_org"`
}

func DefaultConfigPath() (string, error) {
	dir, err := os.UserConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "faciqor", "config.yaml"), nil
}

func Load(customPath string) (*Config, error) {
	v := viper.New()
	v.SetDefault("endpoint", "localhost:50051")
	v.SetDefault("token", "")
	v.SetDefault("default_org", "")

	path := customPath
	if path == "" {
		var err error
		path, err = DefaultConfigPath()
		if err != nil {
			return nil, err
		}
	}

	v.SetConfigFile(path)
	v.SetConfigType("yaml")

	if _, err := os.Stat(path); err == nil {
		if err := v.ReadInConfig(); err != nil {
			return nil, err
		}
	}

	var cfg Config
	if err := v.Unmarshal(&cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}

func Save(cfg *Config, customPath string) error {
	path := customPath
	if path == "" {
		var err error
		path, err = DefaultConfigPath()
		if err != nil {
			return err
		}
	}

	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return err
	}

	v := viper.New()
	v.SetConfigFile(path)
	v.SetConfigType("yaml")
	v.Set("endpoint", cfg.Endpoint)
	v.Set("token", cfg.Token)
	v.Set("default_org", cfg.DefaultOrg)

	return v.WriteConfig()
}
