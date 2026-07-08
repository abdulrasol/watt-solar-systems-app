package handlers

import (
	"watt/internal/database"
	"watt/internal/handlers/companies"
	"watt/internal/models"
)

// buildProfileOut constructs the ProfileOut response matching Django's _serialize_profile
func buildProfileOut(user *models.User) models.ProfileOut {
	var email *string
	if !user.IsDeleted {
		email = &user.Email
	}

	displayName := user.FirstName + " " + user.LastName
	if user.IsDeleted {
		displayName = "Deleted User"
	}

	username := user.Username
	if user.IsDeleted {
		username = "deleted-user"
	}

	firstName := user.FirstName
	if user.IsDeleted {
		firstName = "Deleted"
	}

	lastName := user.LastName
	if user.IsDeleted {
		lastName = "User"
	}

	var cityOut interface{}
	if user.CityID != nil {
		var city models.City
		if err := database.DB.Preload("Country").First(&city, *user.CityID).Error; err == nil {
			cityOut = models.CityOut{
				ID:   city.ID,
				Name: city.Name,
				Code: city.Code,
				Country: models.CountryOut{
					ID:        city.Country.ID,
					Name:      city.Country.Name,
					Code:      city.Country.Code,
					CreatedAt: city.Country.CreatedAt.Format("2006-01-02T15:04:05Z"),
				},
				CreatedAt: city.CreatedAt.Format("2006-01-02T15:04:05Z"),
			}
		}
	}

	isCompanyMember := false
	var companyPayload interface{}

	// If the user is linked to a company, fetch the membership and company details
	var members []models.CompanyMember
	database.DB.Preload("Company.CompanyType").
		Preload("Company.City").
		Preload("Company.Currency").
		Preload("Company.Categories").
		Preload("Company.Contacts").
		Preload("Company.DeliveryOptions").
		Preload("Company.PublicServices").
		Where("user_id = ?", user.ID).Limit(1).Find(&members)
		
	if len(members) > 0 {
		isCompanyMember = true
		companyPayload = companies.BuildCompanyMemberSummary(&members[0].Company, &members[0])
	}

	return models.ProfileOut{
		ID:               user.ID,
		Username:         username,
		Email:            email,
		FirstName:        &firstName,
		LastName:         &lastName,
		Phone:            &user.Phone,
		City:             cityOut,
		ImageURL:         user.Image,
		IsSuperuser:      user.IsSuperuser,
		SecurityQuestion: user.SecurityQuestion,
		SecurityAnswer:   user.SecurityAnswer,
		IsDeleted:        user.IsDeleted,
		IsCompanyMember:  isCompanyMember,
		Company:          companyPayload,
		DisplayName:      &displayName,
	}
}
