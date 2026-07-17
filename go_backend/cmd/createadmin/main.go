package main

import (
	"flag"
	"fmt"
	"os"

	"watt/internal/config"
	"watt/internal/database"
	"watt/internal/models"
	"watt/internal/services"
)

func main() {
	var (
		username = flag.String("username", "", "Admin username")
		email    = flag.String("email", "", "Admin email")
		password = flag.String("password", "", "Admin password")
	)
	flag.Parse()

	if *username == "" || *email == "" || *password == "" {
		fmt.Fprintln(os.Stderr, "Usage: createadmin -username=<name> -email=<email> -password=<password>")
		os.Exit(1)
	}

	cfg := config.LoadConfig()
	database.Connect(cfg)

	var existing models.User
	result := database.DB.Where("username = ? OR email = ?", *username, *email).First(&existing)
	if result.Error == nil {
		fmt.Fprintf(os.Stderr, "User with username '%s' or email '%s' already exists\n", *username, *email)
		os.Exit(1)
	}

	hashedPassword, err := services.GenerateDjangoPassword(*password)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error hashing password: %v\n", err)
		os.Exit(1)
	}

	user := models.User{
		Username:    *username,
		Email:       *email,
		Password:    hashedPassword,
		IsActive:    true,
		IsStaff:     true,
		IsSuperuser: true,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		fmt.Fprintf(os.Stderr, "Error creating user: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Superuser '%s' created successfully (ID: %d)\n", *username, user.ID)
}
