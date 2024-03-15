package main

import (
	"fmt"
	"os"
	"strconv"

	"golang.org/x/crypto/bcrypt"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Missing password")
		os.Exit(1)
	}

	password := os.Args[1]
	cost := 10
	if len(os.Args) > 2 {
		c, err := strconv.Atoi(os.Args[2])
		if err != nil {
			fmt.Fprintf(os.Stderr, "Invalid cost: %s", os.Args[2])
			os.Exit(1)
		}

		cost = c
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(password), cost)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Something went wrong: %s", err.Error())
		os.Exit(1)
	}

	fmt.Println(string(hash))
}
