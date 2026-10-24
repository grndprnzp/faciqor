package main

import (
	"fmt"
	"os"

	"faciqor/internal/cmd"
)

func main() {
	root := cmd.NewRootCmd(nil)
	if err := root.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, "Error:", err)
		os.Exit(1)
	}
}
