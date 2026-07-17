package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"syscall"

	"watt/internal/config"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/services"

	"golang.org/x/term"
)

func main() {
	fmt.Println("Watt Create Admin User")
	fmt.Println("----------------------")

	reader := bufio.NewReader(os.Stdin)

	fmt.Print("Username: ")
	username, err := reader.ReadString('\n')
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading username: %v\n", err)
		os.Exit(1)
	}
	username = strings.TrimSpace(username)

	fmt.Print("Email: ")
	email, err := reader.ReadString('\n')
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading email: %v\n", err)
		os.Exit(1)
	}
	email = strings.TrimSpace(email)

	fmt.Print("Password (hidden): ")
	bytePassword, err := term.ReadPassword(int(syscall.Stdin))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading password: %v\n", err)
		os.Exit(1)
	}
	password := string(bytePassword)
	fmt.Println()

	if username == "" || email == "" || password == "" {
		fmt.Fprintln(os.Stderr, "Username, email and password are required")
		os.Exit(1)
	}

	cfg := config.LoadConfig()
	database.Connect(cfg)

	var existing models.User
	result := database.DB.Where("username = ? OR email = ?", username, email).First(&existing)
	if result.Error == nil {
		fmt.Fprintf(os.Stderr, "User with username '%s' or email '%s' already exists\n", username, email)
		os.Exit(1)
	}

	hashedPassword, err := services.GenerateDjangoPassword(password)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error hashing password: %v\n", err)
		os.Exit(1)
	}

	user := models.User{
		Username:    username,
		Email:       email,
		Password:    hashedPassword,
		IsActive:    true,
		IsStaff:     true,
		IsSuperuser: true,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		fmt.Fprintf(os.Stderr, "Error creating user: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Superuser '%s' created successfully (ID: %d)\n", username, user.ID)
}
